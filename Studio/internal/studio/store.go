package studio

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"sort"
	"strings"
	"time"
	"unicode/utf8"

	"golang.org/x/crypto/scrypt"
	_ "modernc.org/sqlite"
)

var (
	errConflict     = errors.New("conflict")
	errUnauthorized = errors.New("unauthorized")
	errForbidden    = errors.New("forbidden")
	errNotFound     = errors.New("not found")
	errQuota        = errors.New("quota exceeded")
	errConcurrency  = errors.New("model concurrency")
	errInsufficient = errors.New("model amount insufficient")
	errUnavailable  = errors.New("model unavailable")
)

type Store struct {
	db       *sql.DB
	now      func() time.Time
	vaultKey [32]byte
	keyID    string
}

type Account struct {
	AccountID     string `json:"accountId"`
	Enabled       bool   `json:"enabled"`
	Administrator bool   `json:"administrator"`
	Version       int64  `json:"version"`
}

type Session struct {
	AccountID string
	ExpiresAt int64
}

type ProjectFile struct {
	Path   string `json:"path"`
	Kind   string `json:"kind"`
	Text   string `json:"text,omitempty"`
	Base64 string `json:"base64,omitempty"`
}

type ProjectSnapshot struct {
	Version   int           `json:"version"`
	ProjectID string        `json:"projectId"`
	Revision  int64         `json:"revision"`
	Entry     string        `json:"entry"`
	Files     []ProjectFile `json:"files"`
}

type ProjectRecord struct {
	CloudRevision int64           `json:"cloudRevision"`
	Name          string          `json:"name"`
	UpdatedAt     int64           `json:"updatedAt"`
	Snapshot      ProjectSnapshot `json:"snapshot"`
}

type Configuration struct {
	ID         string            `json:"id"`
	Kind       string            `json:"kind"`
	OwnerID    string            `json:"ownerId"`
	Label      string            `json:"label"`
	Model      string            `json:"model"`
	ProviderID string            `json:"providerId"`
	Enabled    bool              `json:"enabled"`
	Version    int64             `json:"version"`
	Pricing    map[string]string `json:"pricing,omitempty"`
}

type ModelScope struct {
	Enabled     bool   `json:"enabled"`
	Limit       int64  `json:"limit"`
	Active      int64  `json:"active"`
	AmountLimit string `json:"amountLimit"`
	Spent       string `json:"spent"`
	Reserved    string `json:"reserved"`
	AccountID   string `json:"accountId,omitempty"`
	APIID       string `json:"apiId,omitempty"`
}

func OpenStore(path string, vaultKey []byte) (*Store, error) {
	if path == "" || len(vaultKey) != 32 {
		return nil, errors.New("invalid store configuration")
	}
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	s := &Store{db: db, now: time.Now, keyID: "studio"}
	copy(s.vaultKey[:], vaultKey)
	if err := s.initialize(); err != nil {
		db.Close()
		return nil, err
	}
	return s, nil
}

func (s *Store) Close() error {
	for i := range s.vaultKey {
		s.vaultKey[i] = 0
	}
	return s.db.Close()
}

func (s *Store) initialize() error {
	_, err := s.db.Exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
CREATE TABLE IF NOT EXISTS studio_sessions(token_hash TEXT PRIMARY KEY,account_id TEXT NOT NULL,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,revoked_at INTEGER);
CREATE INDEX IF NOT EXISTS studio_account_sessions ON studio_sessions(account_id);
CREATE TABLE IF NOT EXISTS studio_accounts(id TEXT PRIMARY KEY,enabled INTEGER NOT NULL,version INTEGER NOT NULL,administrator INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS studio_account_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS studio_invites(code_hash TEXT PRIMARY KEY,administrator INTEGER NOT NULL,expires_at INTEGER NOT NULL,consumed_at INTEGER,created_by TEXT NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS studio_one_bootstrap_invite ON studio_invites(created_by) WHERE created_by='bootstrap';
CREATE TABLE IF NOT EXISTS studio_passwords(account_id TEXT PRIMARY KEY,salt TEXT NOT NULL,verifier TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS studio_login_attempts(key TEXT PRIMARY KEY,started_at INTEGER NOT NULL,count INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS studio_projects(owner TEXT NOT NULL,project TEXT NOT NULL,revision INTEGER NOT NULL,name TEXT NOT NULL,data TEXT NOT NULL,updated_at INTEGER NOT NULL,PRIMARY KEY(owner,project,revision));
CREATE TABLE IF NOT EXISTS studio_project_uploads(owner TEXT NOT NULL,request TEXT NOT NULL,fingerprint TEXT NOT NULL,project TEXT NOT NULL,revision INTEGER NOT NULL,PRIMARY KEY(owner,request));
CREATE TABLE IF NOT EXISTS studio_project_tombstones(owner TEXT NOT NULL,project TEXT NOT NULL,deleted_at INTEGER NOT NULL,PRIMARY KEY(owner,project));
CREATE TABLE IF NOT EXISTS model_configurations(id TEXT PRIMARY KEY,kind TEXT NOT NULL,owner_id TEXT NOT NULL,data TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS owned_model_configurations ON model_configurations(kind,owner_id,id);
CREATE TABLE IF NOT EXISTS model_configuration_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS model_secrets(kind TEXT NOT NULL,owner_id TEXT NOT NULL,configuration_id TEXT NOT NULL,version INTEGER NOT NULL,key_id TEXT,nonce BLOB,ciphertext BLOB,tag BLOB,PRIMARY KEY(kind,owner_id,configuration_id));
CREATE TABLE IF NOT EXISTS model_secret_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,action TEXT NOT NULL,actor_id TEXT NOT NULL,kind TEXT NOT NULL,owner_id TEXT NOT NULL,configuration_id TEXT NOT NULL,version INTEGER NOT NULL,created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS model_scopes(kind TEXT NOT NULL,id TEXT NOT NULL,data TEXT NOT NULL,PRIMARY KEY(kind,id));
CREATE INDEX IF NOT EXISTS model_account_grants ON model_scopes(json_extract(data,'$.accountId'),id) WHERE kind='grant';
CREATE TABLE IF NOT EXISTS model_requests(id TEXT PRIMARY KEY,data TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS model_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS byok_requests(id TEXT PRIMARY KEY,account_id TEXT NOT NULL,data TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS byok_account_requests ON byok_requests(account_id,id);`)
	return err
}

func validIdentity(v string, max int) bool {
	return v != "" && strings.TrimSpace(v) != "" && len(v) <= max && utf8.ValidString(v) && !strings.ContainsAny(v, "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f")
}

func digestString(v string) string { h := sha256.Sum256([]byte(v)); return hex.EncodeToString(h[:]) }
func randomToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

func randomUUID() (string, error) {
	var value [16]byte
	if _, err := rand.Read(value[:]); err != nil {
		return "", err
	}
	value[6] = value[6]&0x0f | 0x40
	value[8] = value[8]&0x3f | 0x80
	encoded := hex.EncodeToString(value[:])
	return encoded[:8] + "-" + encoded[8:12] + "-" + encoded[12:16] + "-" + encoded[16:20] + "-" + encoded[20:], nil
}

func (s *Store) IssueSession(ctx context.Context, accountID string, ttl time.Duration) (string, int64, error) {
	if !validIdentity(accountID, 256) || ttl <= 0 || ttl > 30*24*time.Hour {
		return "", 0, errors.New("invalid session")
	}
	token, err := randomToken()
	if err != nil {
		return "", 0, err
	}
	now, expires := s.now().UnixMilli(), s.now().Add(ttl).UnixMilli()
	_, err = s.db.ExecContext(ctx, `INSERT INTO studio_sessions VALUES(?,?,?,?,NULL)`, digestString(token), accountID, now, expires)
	return token, expires, err
}

func (s *Store) ResolveSession(ctx context.Context, token string) (*Session, error) {
	if len(token) != 43 {
		return nil, nil
	}
	now := s.now().UnixMilli()
	var v Session
	err := s.db.QueryRowContext(ctx, `SELECT account_id,expires_at FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?`, digestString(token), now, now).Scan(&v.AccountID, &v.ExpiresAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &v, nil
}

func (s *Store) RevokeSession(ctx context.Context, token string) error {
	if len(token) != 43 {
		return nil
	}
	_, err := s.db.ExecContext(ctx, `UPDATE studio_sessions SET revoked_at=? WHERE token_hash=? AND revoked_at IS NULL`, s.now().UnixMilli(), digestString(token))
	return err
}

func scanAccount(row interface{ Scan(...any) error }) (*Account, error) {
	var a Account
	var enabled, admin int
	if err := row.Scan(&a.AccountID, &enabled, &admin, &a.Version); err != nil {
		return nil, err
	}
	a.Enabled, a.Administrator = enabled == 1, admin == 1
	return &a, nil
}

func (s *Store) Account(ctx context.Context, id string) (*Account, error) {
	a, err := scanAccount(s.db.QueryRowContext(ctx, `SELECT id,enabled,administrator,version FROM studio_accounts WHERE id=?`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return a, err
}

func (s *Store) IsAllowed(ctx context.Context, id string) bool {
	a, _ := s.Account(ctx, id)
	return a != nil && a.Enabled
}
func (s *Store) IsAdministrator(ctx context.Context, id string) bool {
	a, _ := s.Account(ctx, id)
	return a != nil && a.Enabled && a.Administrator
}

func (s *Store) ListAccounts(ctx context.Context, after string, limit int) ([]Account, bool, error) {
	return s.SearchAccounts(ctx, "", after, limit)
}

func (s *Store) SearchAccounts(ctx context.Context, query, after string, limit int) ([]Account, bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id,enabled,administrator,version FROM studio_accounts WHERE id>? AND (?='' OR instr(lower(id),lower(?))>0) ORDER BY id LIMIT ?`, after, query, query, limit+1)
	if err != nil {
		return nil, false, err
	}
	defer rows.Close()
	items := []Account{}
	for rows.Next() {
		a, err := scanAccount(rows)
		if err != nil {
			return nil, false, err
		}
		items = append(items, *a)
	}
	more := len(items) > limit
	if more {
		items = items[:limit]
	}
	return items, more, rows.Err()
}

type BatchAllowanceUpdate struct {
	AccountID string
	Account   ModelScope
	Grant     *ModelScope
}
type BatchAllowanceResult struct {
	AccountID    string      `json:"accountId"`
	AccountScope *ModelScope `json:"accountScope"`
	GrantID      string      `json:"grantId,omitempty"`
	GrantScope   *ModelScope `json:"grantScope,omitempty"`
}

func (s *Store) AccountAudit(ctx context.Context, after int64, limit int) ([]map[string]any, bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT sequence,data FROM studio_account_audit WHERE sequence>? ORDER BY sequence LIMIT ?`, after, limit+1)
	if err != nil {
		return nil, false, err
	}
	defer rows.Close()
	items := []map[string]any{}
	for rows.Next() {
		var seq int64
		var raw string
		if err := rows.Scan(&seq, &raw); err != nil {
			return nil, false, err
		}
		var v map[string]any
		if err := json.Unmarshal([]byte(raw), &v); err != nil {
			return nil, false, err
		}
		v["sequence"] = seq
		items = append(items, v)
	}
	more := len(items) > limit
	if more {
		items = items[:limit]
	}
	return items, more, rows.Err()
}

func (s *Store) UpdateAccount(ctx context.Context, token, actorID, targetID string, enabled, administrator bool, expected int64) (*Account, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	if err := requireAdminTx(ctx, tx, token, actorID, s.now().UnixMilli()); err != nil {
		return nil, err
	}
	before, err := scanAccount(tx.QueryRowContext(ctx, `SELECT id,enabled,administrator,version FROM studio_accounts WHERE id=?`, targetID))
	if errors.Is(err, sql.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	if before.Version != expected {
		return nil, errConflict
	}
	if before.Enabled && before.Administrator && (!enabled || !administrator) {
		var count int
		if err := tx.QueryRowContext(ctx, `SELECT COUNT(*) FROM studio_accounts WHERE enabled=1 AND administrator=1`).Scan(&count); err != nil {
			return nil, err
		}
		if count <= 1 {
			return nil, errConflict
		}
	}
	after := &Account{AccountID: targetID, Enabled: enabled, Administrator: administrator, Version: expected + 1}
	if _, err = tx.ExecContext(ctx, `UPDATE studio_accounts SET enabled=?,administrator=?,version=? WHERE id=?`, boolInt(enabled), boolInt(administrator), after.Version, targetID); err != nil {
		return nil, err
	}
	audit, _ := json.Marshal(map[string]any{"actorId": actorID, "before": before, "after": after, "createdAt": s.now().UnixMilli()})
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_account_audit(data) VALUES(?)`, string(audit)); err != nil {
		return nil, err
	}
	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return after, nil
}

func requireAdminTx(ctx context.Context, tx *sql.Tx, token, actor string, now int64) error {
	if len(token) != 43 {
		return errUnauthorized
	}
	var id string
	err := tx.QueryRowContext(ctx, `SELECT a.id FROM studio_sessions s JOIN studio_accounts a ON a.id=s.account_id WHERE s.token_hash=? AND s.revoked_at IS NULL AND s.created_at<=? AND s.expires_at>? AND a.enabled=1 AND a.administrator=1`, digestString(token), now, now).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		return errUnauthorized
	}
	if err != nil {
		return err
	}
	if id != actor {
		return errUnauthorized
	}
	return nil
}

func (s *Store) IssueInvite(ctx context.Context, token, actor string, administrator bool, ttl time.Duration) (string, int64, error) {
	if ttl < time.Minute || ttl > 30*24*time.Hour {
		return "", 0, errors.New("invalid invitation")
	}
	code, err := randomToken()
	if err != nil {
		return "", 0, err
	}
	now := s.now().UnixMilli()
	expires := s.now().Add(ttl).UnixMilli()
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return "", 0, err
	}
	defer tx.Rollback()
	if actor == "bootstrap" {
		var count int
		if err = tx.QueryRowContext(ctx, `SELECT COUNT(*) FROM studio_accounts`).Scan(&count); err != nil {
			return "", 0, err
		}
		if count != 0 {
			return "", 0, errConflict
		}
	} else if err = requireAdminTx(ctx, tx, token, actor, now); err != nil {
		return "", 0, err
	}
	_, err = tx.ExecContext(ctx, `INSERT INTO studio_invites VALUES(?,?,?,NULL,?)`, digestString(code), boolInt(administrator), expires, actor)
	if err != nil {
		return "", 0, err
	}
	if err = tx.Commit(); err != nil {
		return "", 0, err
	}
	return code, expires, nil
}

func validAccountID(v string) bool {
	if len(v) < 3 || len(v) > 64 {
		return false
	}
	for i, r := range v {
		if !(r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || i > 0 && strings.ContainsRune("._-", r)) {
			return false
		}
	}
	return true
}

func validPassword(v string) bool { return len(v) >= 12 && len(v) <= 128 && validIdentity(v, 128) }

func derivePassword(password string, salt []byte) ([]byte, error) {
	return scrypt.Key([]byte(password), salt, 16384, 8, 1, 64)
}

func (s *Store) Register(ctx context.Context, code, accountID, password string) error {
	if len(code) != 43 || !validAccountID(accountID) || !validPassword(password) {
		return errors.New("invalid registration")
	}
	var salt [16]byte
	if _, err := rand.Read(salt[:]); err != nil {
		return err
	}
	verifier, err := derivePassword(password, salt[:])
	if err != nil {
		return err
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	now := s.now().UnixMilli()
	var admin int
	if err = tx.QueryRowContext(ctx, `SELECT administrator FROM studio_invites WHERE code_hash=? AND consumed_at IS NULL AND expires_at>?`, digestString(code), now).Scan(&admin); errors.Is(err, sql.ErrNoRows) {
		return errConflict
	}
	if err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_accounts(id,enabled,version,administrator) VALUES(?,1,1,?)`, accountID, admin); err != nil {
		return errConflict
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_passwords VALUES(?,?,?)`, accountID, hex.EncodeToString(salt[:]), hex.EncodeToString(verifier)); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, `UPDATE studio_invites SET consumed_at=? WHERE code_hash=? AND consumed_at IS NULL`, now, digestString(code)); err != nil {
		return err
	}
	a := Account{AccountID: accountID, Enabled: true, Administrator: admin == 1, Version: 1}
	raw, _ := json.Marshal(map[string]any{"actorId": "invitation", "before": nil, "after": a, "createdAt": now})
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_account_audit(data) VALUES(?)`, string(raw)); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *Store) VerifyLogin(ctx context.Context, accountID, password string) (bool, error) {
	if !validAccountID(accountID) || len(password) > 128 || !utf8.ValidString(password) {
		return false, nil
	}
	var saltHex, verifierHex string
	err := s.db.QueryRowContext(ctx, `SELECT p.salt,p.verifier FROM studio_passwords p JOIN studio_accounts a ON a.id=p.account_id WHERE p.account_id=? AND a.enabled=1`, accountID).Scan(&saltHex, &verifierHex)
	if errors.Is(err, sql.ErrNoRows) {
		saltHex = "7e6b80a4c5d8e904b7ad620679c57d5e"
		verifierHex = strings.Repeat("00", 64)
	} else if err != nil {
		return false, err
	}
	salt, _ := hex.DecodeString(saltHex)
	expected, _ := hex.DecodeString(verifierHex)
	actual, err := derivePassword(password, salt)
	if err != nil {
		return false, err
	}
	return len(actual) == len(expected) && subtle.ConstantTimeCompare(actual, expected) == 1 && accountID != "", nil
}

// AllowLoginAttempt implements a fixed-window limiter in SQLite so the limit is
// shared by every Studio process using the database. A permitted attempt is
// recorded before password derivation, matching the fail-closed login flow.
func (s *Store) AllowLoginAttempt(ctx context.Context, key string, maximum int) (bool, error) {
	if key == "" || maximum < 1 {
		return false, errors.New("invalid login attempt limit")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return false, err
	}
	defer tx.Rollback()
	now := s.now().UnixMilli()
	var started int64
	var count int
	err = tx.QueryRowContext(ctx, `SELECT started_at,count FROM studio_login_attempts WHERE key=?`, key).Scan(&started, &count)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return false, err
	}
	if err == nil && now-started < int64((15*time.Minute)/time.Millisecond) && count >= maximum {
		return false, nil
	}
	if errors.Is(err, sql.ErrNoRows) || now-started >= int64((15*time.Minute)/time.Millisecond) {
		_, err = tx.ExecContext(ctx, `INSERT INTO studio_login_attempts(key,started_at,count) VALUES(?,?,1) ON CONFLICT(key) DO UPDATE SET started_at=excluded.started_at,count=1`, key, now)
	} else {
		_, err = tx.ExecContext(ctx, `UPDATE studio_login_attempts SET count=count+1 WHERE key=?`, key)
	}
	if err != nil {
		return false, err
	}
	return true, tx.Commit()
}

func (s *Store) ClearLoginAttempt(ctx context.Context, key string) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM studio_login_attempts WHERE key=?`, key)
	return err
}

func validProjectPath(v string) bool {
	if v == "" || strings.ContainsAny(v, "\\:\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f") {
		return false
	}
	for _, p := range strings.Split(v, "/") {
		if p == "" || p == "." || p == ".." {
			return false
		}
	}
	return true
}

func ValidateSnapshot(v ProjectSnapshot) error {
	if v.Version != 1 || !validIdentity(v.ProjectID, 256) || v.Revision < 0 || !validProjectPath(v.Entry) {
		return errors.New("invalid snapshot")
	}
	seen := map[string]bool{}
	entry := false
	for _, f := range v.Files {
		if !validProjectPath(f.Path) || seen[f.Path] || (f.Kind != "text" && f.Kind != "binary") {
			return errors.New("invalid snapshot")
		}
		seen[f.Path] = true
		if f.Kind == "text" && f.Path == v.Entry {
			entry = true
		}
		if f.Kind == "binary" {
			if _, err := base64.StdEncoding.DecodeString(f.Base64); err != nil {
				return errors.New("invalid snapshot")
			}
		}
	}
	for p := range seen {
		parts := strings.Split(p, "/")
		for len(parts) > 1 {
			parts = parts[:len(parts)-1]
			if seen[strings.Join(parts, "/")] {
				return errors.New("invalid snapshot")
			}
		}
	}
	if !entry {
		return errors.New("invalid snapshot")
	}
	return nil
}

func (s *Store) SaveProject(ctx context.Context, token, owner, requestID string, baseRevision int64, name string, snapshot ProjectSnapshot) (int64, bool, error) {
	if len(token) != 43 || !validIdentity(owner, 256) || !validIdentity(requestID, 256) || !validIdentity(name, 200) || baseRevision < 0 || snapshot.ProjectID == "" {
		return 0, false, errors.New("invalid project")
	}
	if err := ValidateSnapshot(snapshot); err != nil {
		return 0, false, err
	}
	sort.Slice(snapshot.Files, func(i, j int) bool { return snapshot.Files[i].Path < snapshot.Files[j].Path })
	data, _ := json.Marshal(snapshot)
	if len(data) > 32<<20 {
		return 0, false, errQuota
	}
	fingerprint := digestString(fmt.Sprintf("%d\x00%s\x00%s", baseRevision, name, data))
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, false, err
	}
	defer tx.Rollback()
	now := s.now().UnixMilli()
	var sid string
	if err = tx.QueryRowContext(ctx, `SELECT account_id FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?`, digestString(token), now, now).Scan(&sid); err != nil || sid != owner {
		return 0, false, errUnauthorized
	}
	var enabled int
	if err = tx.QueryRowContext(ctx, `SELECT enabled FROM studio_accounts WHERE id=?`, owner).Scan(&enabled); err != nil || enabled != 1 {
		return 0, false, errUnauthorized
	}
	var tomb int
	if err = tx.QueryRowContext(ctx, `SELECT 1 FROM studio_project_tombstones WHERE owner=? AND project=?`, owner, snapshot.ProjectID).Scan(&tomb); err == nil {
		return 0, false, errConflict
	}
	var oldFingerprint string
	var oldRevision int64
	err = tx.QueryRowContext(ctx, `SELECT fingerprint,revision FROM studio_project_uploads WHERE owner=? AND request=?`, owner, requestID).Scan(&oldFingerprint, &oldRevision)
	if err == nil {
		if oldFingerprint != fingerprint {
			return 0, false, errConflict
		}
		return oldRevision, true, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return 0, false, err
	}
	var latest sql.NullInt64
	if err = tx.QueryRowContext(ctx, `SELECT MAX(revision) FROM studio_projects WHERE owner=? AND project=?`, owner, snapshot.ProjectID).Scan(&latest); err != nil {
		return 0, false, err
	}
	current := int64(0)
	if latest.Valid {
		current = latest.Int64
	}
	if current != baseRevision {
		return 0, false, errConflict
	}
	var projects, versions, bytes int64
	if err = tx.QueryRowContext(ctx, `SELECT COUNT(DISTINCT project),COUNT(*),COALESCE(SUM(length(CAST(data AS BLOB))),0) FROM studio_projects WHERE owner=?`, owner).Scan(&projects, &versions, &bytes); err != nil {
		return 0, false, err
	}
	if (current == 0 && projects >= 100) || versions >= 10000 || bytes+int64(len(data)) > 512<<20 {
		return 0, false, errQuota
	}
	revision := current + 1
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_projects VALUES(?,?,?,?,?,?)`, owner, snapshot.ProjectID, revision, strings.TrimSpace(name), string(data), now); err != nil {
		return 0, false, err
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_project_uploads VALUES(?,?,?,?,?)`, owner, requestID, fingerprint, snapshot.ProjectID, revision); err != nil {
		return 0, false, err
	}
	if err = tx.Commit(); err != nil {
		return 0, false, err
	}
	return revision, false, nil
}

func (s *Store) Project(ctx context.Context, owner, project string, revision int64) (*ProjectRecord, error) {
	query := `SELECT revision,name,data,updated_at FROM studio_projects WHERE owner=? AND project=? ORDER BY revision DESC LIMIT 1`
	args := []any{owner, project}
	if revision > 0 {
		query = `SELECT revision,name,data,updated_at FROM studio_projects WHERE owner=? AND project=? AND revision=?`
		args = append(args, revision)
	}
	var r ProjectRecord
	var raw string
	err := s.db.QueryRowContext(ctx, query, args...).Scan(&r.CloudRevision, &r.Name, &raw, &r.UpdatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if err = json.Unmarshal([]byte(raw), &r.Snapshot); err != nil {
		return nil, err
	}
	return &r, nil
}

func (s *Store) ListProjects(ctx context.Context, owner, after string, limit int) ([]map[string]any, bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT current.project,current.revision,current.updated_at,current.name FROM studio_projects current JOIN (SELECT project,MAX(revision) revision FROM studio_projects WHERE owner=? AND project>? GROUP BY project ORDER BY project LIMIT ?) latest ON latest.project=current.project AND latest.revision=current.revision WHERE current.owner=? ORDER BY current.project`, owner, after, limit+1, owner)
	if err != nil {
		return nil, false, err
	}
	defer rows.Close()
	items := []map[string]any{}
	for rows.Next() {
		var id, name string
		var rev, at int64
		if err = rows.Scan(&id, &rev, &at, &name); err != nil {
			return nil, false, err
		}
		items = append(items, map[string]any{"projectId": id, "name": name, "cloudRevision": rev, "updatedAt": at})
	}
	more := len(items) > limit
	if more {
		items = items[:limit]
	}
	return items, more, rows.Err()
}

func (s *Store) ProjectHistory(ctx context.Context, owner, project string, after int64, limit int) ([]map[string]any, bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT revision,updated_at FROM studio_projects WHERE owner=? AND project=? AND revision>? ORDER BY revision LIMIT ?`, owner, project, after, limit+1)
	if err != nil {
		return nil, false, err
	}
	defer rows.Close()
	items := []map[string]any{}
	for rows.Next() {
		var rev, at int64
		if err = rows.Scan(&rev, &at); err != nil {
			return nil, false, err
		}
		items = append(items, map[string]any{"cloudRevision": rev, "updatedAt": at})
	}
	more := len(items) > limit
	if more {
		items = items[:limit]
	}
	return items, more, rows.Err()
}

func (s *Store) DeleteProject(ctx context.Context, owner, project string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err = tx.ExecContext(ctx, `DELETE FROM studio_project_uploads WHERE owner=? AND project=?`, owner, project); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, `DELETE FROM studio_projects WHERE owner=? AND project=?`, owner, project); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO studio_project_tombstones VALUES(?,?,?) ON CONFLICT(owner,project) DO UPDATE SET deleted_at=excluded.deleted_at`, owner, project, s.now().UnixMilli()); err != nil {
		return err
	}
	return tx.Commit()
}

func boolInt(v bool) int {
	if v {
		return 1
	}
	return 0
}
func decimal(v string) *big.Int {
	n, ok := new(big.Int).SetString(v, 10)
	if !ok || n.Sign() < 0 {
		return nil
	}
	return n
}

func (s *Store) GetConfiguration(ctx context.Context, id string) (*Configuration, error) {
	var raw string
	err := s.db.QueryRowContext(ctx, `SELECT data FROM model_configurations WHERE id=?`, id).Scan(&raw)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var c Configuration
	if err = json.Unmarshal([]byte(raw), &c); err != nil {
		return nil, err
	}
	return &c, nil
}
func (s *Store) ListConfigurations(ctx context.Context, kind, owner, after string, limit int) ([]Configuration, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT data FROM model_configurations WHERE kind=? AND owner_id=? AND id>? ORDER BY id LIMIT ?`, kind, owner, after, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Configuration{}
	for rows.Next() {
		var raw string
		if err = rows.Scan(&raw); err != nil {
			return nil, err
		}
		var c Configuration
		if err = json.Unmarshal([]byte(raw), &c); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (s *Store) PutConfiguration(ctx context.Context, c Configuration, expected int64, actor, token string, providers map[string]Provider) (*Configuration, error) {
	if !validSlug(c.ID, 128) || !validIdentity(c.Label, 256) || !validIdentity(c.Model, 256) || providers[c.ProviderID].ID == "" || expected < 0 {
		return nil, errors.New("invalid configuration")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	if c.Kind == "shared" {
		if err = requireAdminTx(ctx, tx, token, actor, s.now().UnixMilli()); err != nil {
			return nil, err
		}
		c.OwnerID = "platform"
	} else if c.Kind != "byok" || c.OwnerID != actor {
		return nil, errForbidden
	}
	var raw string
	err = tx.QueryRowContext(ctx, `SELECT data FROM model_configurations WHERE id=?`, c.ID).Scan(&raw)
	var before *Configuration
	if err == nil {
		before = &Configuration{}
		if err = json.Unmarshal([]byte(raw), before); err != nil {
			return nil, err
		}
	} else if !errors.Is(err, sql.ErrNoRows) {
		return nil, err
	}
	if (before == nil && expected != 0) || (before != nil && before.Version != expected) {
		return nil, errConflict
	}
	if before != nil && (before.Kind != c.Kind || before.OwnerID != c.OwnerID) {
		return nil, errNotFound
	}
	if c.Kind == "shared" {
		if c.Pricing == nil || decimal(c.Pricing["inputNanoCnyPerMillion"]) == nil || decimal(c.Pricing["outputNanoCnyPerMillion"]) == nil {
			return nil, errors.New("pricing required")
		}
		if c.Enabled {
			var ciphertext []byte
			if err = tx.QueryRowContext(ctx, `SELECT ciphertext FROM model_secrets WHERE kind='shared' AND owner_id='platform' AND configuration_id=?`, c.ID).Scan(&ciphertext); err != nil || len(ciphertext) == 0 {
				return nil, errConflict
			}
			scope, err := scopeTx(ctx, tx, "api", c.ID)
			if err != nil || !scope.Enabled || scope.Limit < 1 {
				return nil, errConflict
			}
		}
	} else if before == nil {
		var count int
		if err = tx.QueryRowContext(ctx, `SELECT COUNT(*) FROM model_configurations WHERE kind='byok' AND owner_id=?`, actor).Scan(&count); err != nil {
			return nil, err
		}
		if count >= 100 {
			return nil, errQuota
		}
	}
	c.Version = expected + 1
	encoded, _ := json.Marshal(c)
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_configurations VALUES(?,?,?,?) ON CONFLICT(id) DO UPDATE SET data=excluded.data`, c.ID, c.Kind, c.OwnerID, string(encoded)); err != nil {
		return nil, err
	}
	audit, _ := json.Marshal(map[string]any{"actorId": actor, "before": before, "after": c, "createdAt": s.now().UnixMilli()})
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_configuration_audit(data) VALUES(?)`, string(audit)); err != nil {
		return nil, err
	}
	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return &c, nil
}

func validSlug(v string, max int) bool {
	if len(v) < 1 || len(v) > max {
		return false
	}
	for _, r := range v {
		if !(r >= 'A' && r <= 'Z' || r >= 'a' && r <= 'z' || r >= '0' && r <= '9' || r == '_' || r == '-') {
			return false
		}
	}
	return true
}

func secretAAD(kind, owner, id string, version int64, keyID string) []byte {
	b, _ := json.Marshal([]any{"dora-studio-model-secret", 1, kind, owner, id, version, keyID})
	return b
}
func (s *Store) SecretMetadata(ctx context.Context, kind, owner, id string) (int64, bool, error) {
	var version int64
	var ciphertext []byte
	err := s.db.QueryRowContext(ctx, `SELECT version,ciphertext FROM model_secrets WHERE kind=? AND owner_id=? AND configuration_id=?`, kind, owner, id).Scan(&version, &ciphertext)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, false, nil
	}
	return version, len(ciphertext) > 0, err
}
func (s *Store) PutSecret(ctx context.Context, kind, owner, id string, expected int64, secret []byte, actor, token string) (int64, error) {
	if len(secret) < 1 || len(secret) > 16384 {
		return 0, errors.New("invalid secret")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()
	if kind == "shared" {
		if err = requireAdminTx(ctx, tx, token, actor, s.now().UnixMilli()); err != nil {
			return 0, err
		}
	} else if kind != "byok" || owner != actor {
		return 0, errForbidden
	}
	var old int64
	err = tx.QueryRowContext(ctx, `SELECT version FROM model_secrets WHERE kind=? AND owner_id=? AND configuration_id=?`, kind, owner, id).Scan(&old)
	if errors.Is(err, sql.ErrNoRows) {
		old = 0
	} else if err != nil {
		return 0, err
	}
	if old != expected {
		return 0, errConflict
	}
	block, _ := aes.NewCipher(s.vaultKey[:])
	gcm, _ := cipher.NewGCM(block)
	nonce := make([]byte, gcm.NonceSize())
	if _, err = rand.Read(nonce); err != nil {
		return 0, err
	}
	version := expected + 1
	sealed := gcm.Seal(nil, nonce, secret, secretAAD(kind, owner, id, version, s.keyID))
	tagSize := gcm.Overhead()
	ciphertext, tag := sealed[:len(sealed)-tagSize], sealed[len(sealed)-tagSize:]
	_, err = tx.ExecContext(ctx, `INSERT INTO model_secrets VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(kind,owner_id,configuration_id) DO UPDATE SET version=excluded.version,key_id=excluded.key_id,nonce=excluded.nonce,ciphertext=excluded.ciphertext,tag=excluded.tag`, kind, owner, id, version, s.keyID, nonce, ciphertext, tag)
	if err != nil {
		return 0, err
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_secret_audit VALUES(NULL,'put',?,?,?,?,?,?)`, actor, kind, owner, id, version, s.now().UnixMilli()); err != nil {
		return 0, err
	}
	return version, tx.Commit()
}
func (s *Store) RevokeSecret(ctx context.Context, kind, owner, id string, expected int64, actor, token string) (int64, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()
	if kind == "shared" {
		if err = requireAdminTx(ctx, tx, token, actor, s.now().UnixMilli()); err != nil {
			return 0, err
		}
		var raw string
		if err = tx.QueryRowContext(ctx, `SELECT data FROM model_configurations WHERE id=? AND kind='shared'`, id).Scan(&raw); err != nil {
			return 0, errNotFound
		}
		var c Configuration
		json.Unmarshal([]byte(raw), &c)
		if c.Enabled {
			return 0, errConflict
		}
	} else if kind != "byok" || owner != actor {
		return 0, errForbidden
	}
	var old int64
	if err = tx.QueryRowContext(ctx, `SELECT version FROM model_secrets WHERE kind=? AND owner_id=? AND configuration_id=?`, kind, owner, id).Scan(&old); err != nil {
		return 0, errConflict
	}
	if old != expected {
		return 0, errConflict
	}
	version := expected + 1
	if _, err = tx.ExecContext(ctx, `UPDATE model_secrets SET version=?,key_id=NULL,nonce=NULL,ciphertext=NULL,tag=NULL WHERE kind=? AND owner_id=? AND configuration_id=?`, version, kind, owner, id); err != nil {
		return 0, err
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_secret_audit VALUES(NULL,'revoke',?,?,?,?,?,?)`, actor, kind, owner, id, version, s.now().UnixMilli()); err != nil {
		return 0, err
	}
	return version, tx.Commit()
}
func (s *Store) WithSecret(ctx context.Context, kind, owner, id string, fn func([]byte, int64) error) error {
	var version int64
	var keyID string
	var nonce, ciphertext, tag []byte
	if err := s.db.QueryRowContext(ctx, `SELECT version,key_id,nonce,ciphertext,tag FROM model_secrets WHERE kind=? AND owner_id=? AND configuration_id=?`, kind, owner, id).Scan(&version, &keyID, &nonce, &ciphertext, &tag); err != nil {
		return errNotFound
	}
	if keyID != s.keyID || len(ciphertext) == 0 {
		return errNotFound
	}
	block, _ := aes.NewCipher(s.vaultKey[:])
	gcm, _ := cipher.NewGCM(block)
	sealed := append(append([]byte{}, ciphertext...), tag...)
	plain, err := gcm.Open(nil, nonce, sealed, secretAAD(kind, owner, id, version, keyID))
	if err != nil {
		return err
	}
	defer func() {
		for i := range plain {
			plain[i] = 0
		}
	}()
	return fn(plain, version)
}

func scopeTx(ctx context.Context, q interface {
	QueryRowContext(context.Context, string, ...any) *sql.Row
}, kind, id string) (*ModelScope, error) {
	var raw string
	if err := q.QueryRowContext(ctx, `SELECT data FROM model_scopes WHERE kind=? AND id=?`, kind, id).Scan(&raw); err != nil {
		return nil, err
	}
	return decodeScope(raw)
}

func decodeNano(raw json.RawMessage) string {
	if len(raw) == 0 || string(raw) == "null" {
		return "0"
	}
	var text string
	if json.Unmarshal(raw, &text) == nil && decimal(text) != nil {
		return text
	}
	var tagged map[string]string
	if json.Unmarshal(raw, &tagged) == nil && decimal(tagged["$nano"]) != nil {
		return tagged["$nano"]
	}
	var number json.Number
	if json.Unmarshal(raw, &number) == nil && decimal(number.String()) != nil {
		return number.String()
	}
	return "0"
}
func decodeScope(raw string) (*ModelScope, error) {
	var m map[string]json.RawMessage
	if err := json.Unmarshal([]byte(raw), &m); err != nil {
		return nil, err
	}
	var v ModelScope
	_ = json.Unmarshal(m["enabled"], &v.Enabled)
	_ = json.Unmarshal(m["limit"], &v.Limit)
	_ = json.Unmarshal(m["active"], &v.Active)
	_ = json.Unmarshal(m["accountId"], &v.AccountID)
	_ = json.Unmarshal(m["apiId"], &v.APIID)
	v.AmountLimit = decodeNano(m["amountLimit"])
	v.Spent = decodeNano(m["spent"])
	v.Reserved = decodeNano(m["reserved"])
	return &v, nil
}
func encodeScope(v ModelScope) string {
	m := map[string]any{"enabled": v.Enabled, "limit": v.Limit, "active": v.Active, "amountLimit": map[string]string{"$nano": zeroNano(v.AmountLimit)}, "spent": map[string]string{"$nano": zeroNano(v.Spent)}, "reserved": map[string]string{"$nano": zeroNano(v.Reserved)}}
	if v.AccountID != "" {
		m["accountId"] = v.AccountID
	}
	if v.APIID != "" {
		m["apiId"] = v.APIID
	}
	raw, _ := json.Marshal(m)
	return string(raw)
}
func zeroNano(v string) string {
	if decimal(v) == nil {
		return "0"
	}
	return v
}
func (s *Store) Scope(ctx context.Context, kind, id string) (*ModelScope, error) {
	return scopeTx(ctx, s.db, kind, id)
}
func (s *Store) ConfigureScope(ctx context.Context, kind, id string, v ModelScope, actor, token string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if err = requireAdminTx(ctx, tx, token, actor, s.now().UnixMilli()); err != nil {
		return err
	}
	var before *ModelScope
	before, _ = scopeTx(ctx, tx, kind, id)
	if before != nil {
		v.Active = before.Active
		v.Spent = before.Spent
		v.Reserved = before.Reserved
	} else {
		v.Spent = "0"
		v.Reserved = "0"
	}
	if kind == "grant" {
		if _, err = scopeTx(ctx, tx, "account", v.AccountID); err != nil {
			return errNotFound
		}
		if _, err = scopeTx(ctx, tx, "api", v.APIID); err != nil {
			return errNotFound
		}
		if before != nil && (before.AccountID != v.AccountID || before.APIID != v.APIID) {
			return errConflict
		}
	}
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_scopes VALUES(?,?,?) ON CONFLICT(kind,id) DO UPDATE SET data=excluded.data`, kind, id, encodeScope(v)); err != nil {
		return err
	}
	audit, _ := json.Marshal(map[string]any{"timestamp": s.now().UnixMilli(), "action": "configure", "actorId": actor, "kind": kind, "scopeId": id, "before": before, "after": v})
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_audit(data) VALUES(?)`, string(audit)); err != nil {
		return err
	}
	return tx.Commit()
}

func configureScopeTx(ctx context.Context, tx *sql.Tx, kind, id string, v ModelScope, actor string, timestamp int64) (*ModelScope, error) {
	before, _ := scopeTx(ctx, tx, kind, id)
	if before != nil {
		v.Active, v.Spent, v.Reserved = before.Active, before.Spent, before.Reserved
	} else {
		v.Spent, v.Reserved = "0", "0"
	}
	if kind == "grant" {
		if _, err := scopeTx(ctx, tx, "account", v.AccountID); err != nil {
			return nil, errNotFound
		}
		if _, err := scopeTx(ctx, tx, "api", v.APIID); err != nil {
			return nil, errNotFound
		}
		if before != nil && (before.AccountID != v.AccountID || before.APIID != v.APIID) {
			return nil, errConflict
		}
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO model_scopes VALUES(?,?,?) ON CONFLICT(kind,id) DO UPDATE SET data=excluded.data`, kind, id, encodeScope(v)); err != nil {
		return nil, err
	}
	audit, _ := json.Marshal(map[string]any{"timestamp": timestamp, "action": "configure", "actorId": actor, "kind": kind, "scopeId": id, "before": before, "after": v})
	if _, err := tx.ExecContext(ctx, `INSERT INTO model_audit(data) VALUES(?)`, string(audit)); err != nil {
		return nil, err
	}
	return &v, nil
}

func (s *Store) ConfigureAllowancesBatch(ctx context.Context, updates []BatchAllowanceUpdate, actor, token string) ([]BatchAllowanceResult, error) {
	if len(updates) < 1 || len(updates) > 100 {
		return nil, errors.New("invalid batch")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	timestamp := s.now().UnixMilli()
	if err = requireAdminTx(ctx, tx, token, actor, timestamp); err != nil {
		return nil, err
	}
	results := make([]BatchAllowanceResult, 0, len(updates))
	seen := map[string]bool{}
	for _, update := range updates {
		if !validIdentity(update.AccountID, 256) || seen[update.AccountID] {
			return nil, errors.New("invalid batch account")
		}
		seen[update.AccountID] = true
		var exists int
		if err = tx.QueryRowContext(ctx, `SELECT 1 FROM studio_accounts WHERE id=?`, update.AccountID).Scan(&exists); err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, errNotFound
			}
			return nil, err
		}
		accountScope, applyErr := configureScopeTx(ctx, tx, "account", update.AccountID, update.Account, actor, timestamp)
		if applyErr != nil {
			return nil, applyErr
		}
		result := BatchAllowanceResult{AccountID: update.AccountID, AccountScope: accountScope}
		if update.Grant != nil {
			grant := *update.Grant
			grant.AccountID = update.AccountID
			var grantID string
			err = tx.QueryRowContext(ctx, `SELECT id FROM model_scopes WHERE kind='grant' AND json_extract(data,'$.accountId')=? AND json_extract(data,'$.apiId')=? ORDER BY id LIMIT 1`, update.AccountID, grant.APIID).Scan(&grantID)
			if errors.Is(err, sql.ErrNoRows) {
				grantID, err = randomUUID()
			}
			if err != nil {
				return nil, err
			}
			grantScope, applyErr := configureScopeTx(ctx, tx, "grant", grantID, grant, actor, timestamp)
			if applyErr != nil {
				return nil, applyErr
			}
			result.GrantID, result.GrantScope = grantID, grantScope
		}
		results = append(results, result)
	}
	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return results, nil
}

func (s *Store) OwnedGrant(ctx context.Context, account, grant string) (string, bool) {
	v, err := s.Scope(ctx, "grant", grant)
	return func() (string, bool) {
		if err != nil || v.AccountID != account {
			return "", false
		}
		return v.APIID, true
	}()
}
func (s *Store) Grants(ctx context.Context, account, after string, limit int) ([]map[string]any, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id,data FROM model_scopes WHERE kind='grant' AND json_extract(data,'$.accountId')=? AND id>? ORDER BY id LIMIT ?`, account, after, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []map[string]any{}
	for rows.Next() {
		var id, raw string
		if err = rows.Scan(&id, &raw); err != nil {
			return nil, err
		}
		v, decodeErr := decodeScope(raw)
		if decodeErr != nil {
			err = decodeErr
			return nil, err
		}
		out = append(out, map[string]any{"grantId": id, "apiId": v.APIID, "scope": v})
	}
	return out, rows.Err()
}

type ModelIntent struct {
	RequestID, AccountID, APIID, GrantID, Fingerprint string
	ConfigurationVersion                              int64
	Reservation, InputRate, OutputRate                *big.Int
}
type ModelUsage struct{ InputTokens, OutputTokens *big.Int }

func tagged(v *big.Int) map[string]string {
	if v == nil {
		v = new(big.Int)
	}
	return map[string]string{"$nano": v.String()}
}
func addNano(current string, delta *big.Int) string {
	return new(big.Int).Add(orZero(decimal(current)), orZero(delta)).String()
}
func subNano(current string, delta *big.Int) string {
	v := new(big.Int).Sub(orZero(decimal(current)), orZero(delta))
	if v.Sign() < 0 {
		v.SetInt64(0)
	}
	return v.String()
}

func (s *Store) BeginModelRequest(ctx context.Context, in ModelIntent) error {
	if !validIdentity(in.RequestID, 256) || !validIdentity(in.Fingerprint, 256) || in.Reservation == nil || in.Reservation.Sign() < 0 {
		return errors.New("invalid model intent")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	var existing string
	err = tx.QueryRowContext(ctx, `SELECT data FROM model_requests WHERE id=?`, in.RequestID).Scan(&existing)
	if err == nil {
		return errConflict
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return err
	}
	var configRaw string
	if err = tx.QueryRowContext(ctx, `SELECT data FROM model_configurations WHERE id=? AND kind='shared' AND owner_id='platform'`, in.APIID).Scan(&configRaw); err != nil {
		return errUnavailable
	}
	var c Configuration
	if json.Unmarshal([]byte(configRaw), &c) != nil || !c.Enabled || c.Version != in.ConfigurationVersion {
		return errUnavailable
	}
	api, err := scopeTx(ctx, tx, "api", in.APIID)
	if err != nil {
		return errUnavailable
	}
	account, err := scopeTx(ctx, tx, "account", in.AccountID)
	if err != nil {
		return errUnavailable
	}
	grant, err := scopeTx(ctx, tx, "grant", in.GrantID)
	if err != nil || grant.AccountID != in.AccountID || grant.APIID != in.APIID {
		return errUnavailable
	}
	for _, scope := range []*ModelScope{api, account, grant} {
		if !scope.Enabled || scope.Limit < 1 {
			return errUnavailable
		}
		if scope.Active >= scope.Limit {
			return errConcurrency
		}
	}
	available := minimumScopeAvailable(account, grant)
	if apiLimit := decimal(api.AmountLimit); apiLimit != nil && apiLimit.Sign() > 0 {
		available = minimumScopeAmount(available, scopeAmountAvailable(api))
	}
	if available.Cmp(in.Reservation) < 0 {
		return errInsufficient
	}
	for _, scope := range []*ModelScope{api, account, grant} {
		scope.Active++
	}
	for _, scope := range []*ModelScope{api, account, grant} {
		scope.Reserved = addNano(scope.Reserved, in.Reservation)
	}
	for _, entry := range []struct {
		kind, id string
		scope    *ModelScope
	}{{"api", in.APIID, api}, {"account", in.AccountID, account}, {"grant", in.GrantID, grant}} {
		if _, err = tx.ExecContext(ctx, `UPDATE model_scopes SET data=? WHERE kind=? AND id=?`, encodeScope(*entry.scope), entry.kind, entry.id); err != nil {
			return err
		}
	}
	record := map[string]any{"binding": map[string]any{"accountId": in.AccountID, "apiId": in.APIID, "grantId": in.GrantID, "fingerprint": in.Fingerprint, "reservation": tagged(in.Reservation), "configurationVersion": in.ConfigurationVersion, "rates": map[string]any{"inputNanoCnyPerMillion": tagged(in.InputRate), "outputNanoCnyPerMillion": tagged(in.OutputRate)}}, "version": 2, "request": map[string]any{"state": "in-flight", "reservation": tagged(in.Reservation), "rates": map[string]any{"inputNanoCnyPerMillion": tagged(in.InputRate), "outputNanoCnyPerMillion": tagged(in.OutputRate)}}}
	raw, _ := json.Marshal(record)
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_requests(id,data) VALUES(?,?)`, in.RequestID, string(raw)); err != nil {
		return err
	}
	audit, _ := json.Marshal(map[string]any{"timestamp": s.now().UnixMilli(), "action": "dispatch", "requestId": in.RequestID, "accountId": in.AccountID, "apiId": in.APIID, "grantId": in.GrantID, "version": 2})
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_audit(data) VALUES(?)`, string(audit)); err != nil {
		return err
	}
	return tx.Commit()
}

func minimumScopeAvailable(scopes ...*ModelScope) *big.Int {
	var minimum *big.Int
	for _, scope := range scopes {
		minimum = minimumScopeAmount(minimum, scopeAmountAvailable(scope))
	}
	return orZero(minimum)
}
func scopeAmountAvailable(scope *ModelScope) *big.Int {
	available := new(big.Int).Sub(orZero(decimal(scope.AmountLimit)), orZero(decimal(scope.Spent)))
	available.Sub(available, orZero(decimal(scope.Reserved)))
	if available.Sign() < 0 {
		available.SetInt64(0)
	}
	return available
}
func minimumScopeAmount(current, candidate *big.Int) *big.Int {
	if current == nil || candidate.Cmp(current) < 0 {
		return candidate
	}
	return current
}

func charge(tokens, rate *big.Int) *big.Int {
	if tokens == nil || rate == nil {
		return new(big.Int)
	}
	n := new(big.Int).Mul(tokens, rate)
	million := big.NewInt(1_000_000)
	n.Add(n, new(big.Int).Sub(million, big.NewInt(1)))
	return n.Div(n, million)
}
func (s *Store) FinishModelRequest(ctx context.Context, id string, usage *ModelUsage) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	var raw string
	if err = tx.QueryRowContext(ctx, `SELECT data FROM model_requests WHERE id=?`, id).Scan(&raw); err != nil {
		return err
	}
	var record map[string]json.RawMessage
	if err = json.Unmarshal([]byte(raw), &record); err != nil {
		return err
	}
	var binding struct {
		AccountID   string                     `json:"accountId"`
		APIID       string                     `json:"apiId"`
		GrantID     string                     `json:"grantId"`
		Reservation json.RawMessage            `json:"reservation"`
		Rates       map[string]json.RawMessage `json:"rates"`
	}
	if err = json.Unmarshal(record["binding"], &binding); err != nil {
		return err
	}
	reservation := decimal(decodeNano(binding.Reservation))
	inputRate := decimal(decodeNano(binding.Rates["inputNanoCnyPerMillion"]))
	outputRate := decimal(decodeNano(binding.Rates["outputNanoCnyPerMillion"]))
	api, err := scopeTx(ctx, tx, "api", binding.APIID)
	if err != nil {
		return err
	}
	account, err := scopeTx(ctx, tx, "account", binding.AccountID)
	if err != nil {
		return err
	}
	grant, err := scopeTx(ctx, tx, "grant", binding.GrantID)
	if err != nil {
		return err
	}
	for _, v := range []*ModelScope{api, account, grant} {
		if v.Active > 0 {
			v.Active--
		}
	}
	actual := new(big.Int)
	state := "pending-usage"
	var usageValue any = nil
	if usage != nil {
		actual.Add(charge(usage.InputTokens, inputRate), charge(usage.OutputTokens, outputRate))
		for _, scope := range []*ModelScope{api, account, grant} {
			scope.Reserved = subNano(scope.Reserved, reservation)
			scope.Spent = addNano(scope.Spent, actual)
		}
		state = "settled"
		usageValue = map[string]any{"inputTokens": tagged(usage.InputTokens), "outputTokens": tagged(usage.OutputTokens)}
	}
	for _, entry := range []struct {
		kind, id string
		scope    *ModelScope
	}{{"api", binding.APIID, api}, {"account", binding.AccountID, account}, {"grant", binding.GrantID, grant}} {
		if _, err = tx.ExecContext(ctx, `UPDATE model_scopes SET data=? WHERE kind=? AND id=?`, encodeScope(*entry.scope), entry.kind, entry.id); err != nil {
			return err
		}
	}
	var request map[string]any
	_ = json.Unmarshal(record["request"], &request)
	request["state"] = state
	request["usage"] = usageValue
	request["actual"] = tagged(actual)
	record["request"], _ = json.Marshal(request)
	record["receipt"], _ = json.Marshal(map[string]any{"usage": usageValue})
	record["version"], _ = json.Marshal(3)
	updated, _ := json.Marshal(record)
	if _, err = tx.ExecContext(ctx, `UPDATE model_requests SET data=? WHERE id=?`, string(updated), id); err != nil {
		return err
	}
	audit, _ := json.Marshal(map[string]any{"timestamp": s.now().UnixMilli(), "action": "finish", "requestId": id, "accountId": binding.AccountID, "apiId": binding.APIID, "grantId": binding.GrantID, "version": 3, "state": state})
	if _, err = tx.ExecContext(ctx, `INSERT INTO model_audit(data) VALUES(?)`, string(audit)); err != nil {
		return err
	}
	return tx.Commit()
}
