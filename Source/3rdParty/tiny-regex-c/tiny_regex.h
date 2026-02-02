/*
 *
 * Mini regex-module inspired by Rob Pike's regex code described in:
 *
 * http://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html
 *
 *
 *
 * Supports:
 * ---------
 *   '.'        Dot, matches any character
 *   '^'        Start anchor, matches beginning of string
 *   '$'        End anchor, matches end of string
 *   '*'        Asterisk, match zero or more (greedy)
 *   '+'        Plus, match one or more (greedy)
 *   '?'        Question, match zero or one (non-greedy)
 *   '[abc]'    Character class, match if one of {'a', 'b', 'c'}
 *   '[^abc]'   Inverted class, match if NOT one of {'a', 'b', 'c'}
 *   '[a-zA-Z]' Character ranges, the character set of the ranges { a-z | A-Z }
 *   '\s'       Whitespace, \t \f \r \n \v and spaces
 *   '\S'       Non-whitespace
 *   '\w'       Alphanumeric, [a-zA-Z0-9_]
 *   '\W'       Non-alphanumeric
 *   '\d'       Digits, [0-9]
 *   '\D'       Non-digits
 *
 * tiny-regex-c (public domain)
 * https://github.com/kokke/tiny-regex-c
 *
 * This header merges the original re.h + re.c into a single header-only
 * implementation. Define TINY_REGEX_IMPLEMENTATION in one translation unit
 * before including this file to compile the implementation.
 */

#ifndef DORA_TINY_REGEX_H
#define DORA_TINY_REGEX_H

#ifndef RE_DOT_MATCHES_NEWLINE
/* Define to 0 if you DON'T want '.' to match '\r' + '\n' */
#define RE_DOT_MATCHES_NEWLINE 1
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Typedef'd pointer to get abstract datatype. */
typedef struct regex_t* re_t;

/* Compile regex string pattern to a regex_t-array. */
re_t re_compile(const char* pattern);

/* Find matches of the compiled pattern inside text. */
int re_matchp(re_t pattern, const char* text, int* matchlength);

/* Find matches of the txt pattern inside text (will compile automatically first). */
int re_match(const char* pattern, const char* text, int* matchlength);

#ifdef __cplusplus
}
#endif

#ifdef TINY_REGEX_IMPLEMENTATION

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>

#if defined(__cplusplus) && __cplusplus >= 201103L
#define TINY_REGEX_THREAD_LOCAL thread_local
#else
#define TINY_REGEX_THREAD_LOCAL
#endif

/* Definitions: */

#define MAX_REGEXP_OBJECTS      30    /* Max number of regex symbols in expression. */
#define MAX_CHAR_CLASS_LEN      40    /* Max length of character-class buffer in.   */


enum { UNUSED, DOT, BEGIN, END, QUESTIONMARK, STAR, PLUS, CHA, CHAR_CLASS, INV_CHAR_CLASS, DIGIT, NOT_DIGIT, ALPHA, NOT_ALPHA, WHITESPACE, NOT_WHITESPACE, /* BRANCH */ };

typedef struct regex_t
{
  unsigned char  type;   /* CHA, STAR, etc.                      */
  union
  {
    uint32_t  ch;        /*      the character (Unicode codepoint) */
    uint32_t* ccl;       /*  OR  a pointer to characters in class */
  } u;
} regex_t;



/* Private function declarations: */
static int matchpattern(regex_t* pattern, const char* text, int* matchlength);
static int matchcharclass(uint32_t c, const uint32_t* str);
static int matchstar(regex_t p, regex_t* pattern, const char* text, int* matchlength);
static int matchplus(regex_t p, regex_t* pattern, const char* text, int* matchlength);
static int matchone(regex_t p, uint32_t c);
static int matchdigit(uint32_t c);
static int matchalpha(uint32_t c);
static int matchwhitespace(uint32_t c);
static int matchmetachar(uint32_t c, const uint32_t* str);
static int matchrange(uint32_t c, const uint32_t* str);
static int matchdot(uint32_t c);
static int ismetachar(uint32_t c);
static int utf8_decode(const char* s, uint32_t* out);
static const char* utf8_prev(const char* start, const char* cur);
static int utf8_encode(uint32_t cp, char out[5]);



/* Public functions: */
int re_match(const char* pattern, const char* text, int* matchlength)
{
  return re_matchp(re_compile(pattern), text, matchlength);
}

int re_matchp(re_t pattern, const char* text, int* matchlength)
{
  *matchlength = 0;
  if (pattern != 0)
  {
    if (pattern[0].type == BEGIN)
    {
      return ((matchpattern(&pattern[1], text, matchlength)) ? 0 : -1);
    }
    else
    {
      int idx = 0;

      do
      {
        if (matchpattern(pattern, text, matchlength))
        {
          if (text[0] == '\0')
            return -1;

          return idx;
        }
        if (text[0] == '\0')
        {
          break;
        }
        {
          uint32_t cp = 0;
          int bytes = utf8_decode(text, &cp);
          text += bytes;
          idx += bytes;
        }
      }
      while (text[0] != '\0');
    }
  }
  return -1;
}

re_t re_compile(const char* pattern)
{
  /* The sizes of the two static arrays below substantiates the static RAM usage of this module.
     MAX_REGEXP_OBJECTS is the max number of symbols in the expression.
     MAX_CHAR_CLASS_LEN determines the size of buffer for chars in all char-classes in the expression. */
  static TINY_REGEX_THREAD_LOCAL regex_t re_compiled[MAX_REGEXP_OBJECTS];
  static TINY_REGEX_THREAD_LOCAL uint32_t ccl_buf[MAX_CHAR_CLASS_LEN];
  int ccl_bufidx = 1;

  char c;     /* current char in pattern   */
  int i = 0;  /* index into pattern        */
  int j = 0;  /* index into re_compiled    */

  while (pattern[i] != '\0' && (j+1 < MAX_REGEXP_OBJECTS))
  {
    c = pattern[i];

    switch (c)
    {
      /* Meta-characters: */
      case '^': {    re_compiled[j].type = BEGIN;           } break;
      case '$': {    re_compiled[j].type = END;             } break;
      case '.': {    re_compiled[j].type = DOT;             } break;
      case '*': {    re_compiled[j].type = STAR;            } break;
      case '+': {    re_compiled[j].type = PLUS;            } break;
      case '?': {    re_compiled[j].type = QUESTIONMARK;    } break;
/*    case '|': {    re_compiled[j].type = BRANCH;          } break; <-- not working properly */

      /* Escaped character-classes (\s \w ...): */
      case '\\':
      {
        if (pattern[i+1] != '\0')
        {
          /* Skip the escape-char '\\' */
          i += 1;
          /* ... and check the next */
          switch (pattern[i])
          {
            /* Meta-character: */
            case 'd': {    re_compiled[j].type = DIGIT;            } break;
            case 'D': {    re_compiled[j].type = NOT_DIGIT;        } break;
            case 'w': {    re_compiled[j].type = ALPHA;            } break;
            case 'W': {    re_compiled[j].type = NOT_ALPHA;        } break;
            case 's': {    re_compiled[j].type = WHITESPACE;       } break;
            case 'S': {    re_compiled[j].type = NOT_WHITESPACE;   } break;

            /* Escaped character, e.g. '.' or '$' */
            default:
            {
              uint32_t cp = 0;
              int bytes = utf8_decode(&pattern[i], &cp);
              re_compiled[j].type = CHA;
              re_compiled[j].u.ch = cp;
              i += (bytes - 1);
            } break;
          }
        }
        /* '\\' as last char in pattern -> invalid regular expression. */
/*
        else
        {
          re_compiled[j].type = CHA;
          re_compiled[j].ch = pattern[i];
        }
*/
      } break;

      /* Character class: */
      case '[':
      {
        /* Remember where the char-buffer starts. */
        int buf_begin = ccl_bufidx;

        /* Look-ahead to determine if negated */
        if (pattern[i+1] == '^')
        {
          re_compiled[j].type = INV_CHAR_CLASS;
          i += 1; /* Increment i to avoid including '^' in the char-buffer */
          if (pattern[i+1] == 0) /* incomplete pattern, missing non-zero char after '^' */
          {
            return 0;
          }
        }
        else
        {
          re_compiled[j].type = CHAR_CLASS;
        }

        /* Copy characters inside [..] to buffer */
        i += 1;
        while ((pattern[i] != ']') && (pattern[i] != '\0')) /* Missing ] */
        {
          if (pattern[i] == '\\')
          {
            if (ccl_bufidx >= MAX_CHAR_CLASS_LEN - 2)
            {
              //fputs("exceeded internal buffer!\n", stderr);
              return 0;
            }
            if (pattern[i+1] == 0) /* incomplete pattern, missing non-zero char after '\\' */
            {
              return 0;
            }
            ccl_buf[ccl_bufidx++] = '\\';
            i += 1;
            {
              uint32_t cp = 0;
              int bytes = utf8_decode(&pattern[i], &cp);
              ccl_buf[ccl_bufidx++] = cp;
              i += bytes;
            }
            continue;
          }
          if (ccl_bufidx >= MAX_CHAR_CLASS_LEN - 1)
          {
              //fputs("exceeded internal buffer!\n", stderr);
              return 0;
          }
          {
            uint32_t cp = 0;
            int bytes = utf8_decode(&pattern[i], &cp);
            ccl_buf[ccl_bufidx++] = cp;
            i += bytes;
          }
        }
        if (ccl_bufidx >= MAX_CHAR_CLASS_LEN)
        {
            /* Catches cases such as [00000000000000000000000000000000000000][ */
            //fputs("exceeded internal buffer!\n", stderr);
            return 0;
        }
        /* Null-terminate string end */
        ccl_buf[ccl_bufidx++] = 0;
        re_compiled[j].u.ccl = &ccl_buf[buf_begin];
      } break;

      /* Other characters: */
      default:
      {
        uint32_t cp = 0;
        int bytes = utf8_decode(&pattern[i], &cp);
        re_compiled[j].type = CHA;
        re_compiled[j].u.ch = cp;
        i += (bytes - 1);
      } break;
    }
    /* no buffer-out-of-bounds access on invalid patterns - see https://github.com/kokke/tiny-regex-c/commit/1a279e04014b70b0695fba559a7c05d55e6ee90b */
    if (pattern[i] == 0)
    {
      return 0;
    }

    i += 1;
    j += 1;
  }
  /* 'UNUSED' is a sentinel used to indicate end-of-pattern */
  re_compiled[j].type = UNUSED;

  return (re_t) re_compiled;
}

void re_print(regex_t* pattern)
{
  const char* types[] = { "UNUSED", "DOT", "BEGIN", "END", "QUESTIONMARK", "STAR", "PLUS", "CHAR", "CHAR_CLASS", "INV_CHAR_CLASS", "DIGIT", "NOT_DIGIT", "ALPHA", "NOT_ALPHA", "WHITESPACE", "NOT_WHITESPACE", "BRANCH" };

  int i;
  int j;
  uint32_t c;
  for (i = 0; i < MAX_REGEXP_OBJECTS; ++i)
  {
    if (pattern[i].type == UNUSED)
    {
      break;
    }

    printf("type: %s", types[pattern[i].type]);
    if (pattern[i].type == CHAR_CLASS || pattern[i].type == INV_CHAR_CLASS)
    {
      printf(" [");
      for (j = 0; j < MAX_CHAR_CLASS_LEN; ++j)
      {
        c = pattern[i].u.ccl[j];
        if ((c == 0) || (c == ']'))
        {
          break;
        }
        {
          char out[5] = {0,0,0,0,0};
          int len = utf8_encode(c, out);
          if (len > 0)
          {
            fwrite(out, 1, (size_t)len, stdout);
          }
        }
      }
      printf("]");
    }
    else if (pattern[i].type == CHA)
    {
      char out[5] = {0,0,0,0,0};
      int len = utf8_encode(pattern[i].u.ch, out);
      if (len > 0)
      {
        printf(" '%s'", out);
      }
      else
      {
        printf(" '?'");
      }
    }
    printf("\n");
  }
}



/* Private functions: */
static int matchdigit(uint32_t c)
{
  return (c < 128) ? isdigit((int)c) : 0;
}
static int matchalpha(uint32_t c)
{
  return (c < 128) ? isalpha((int)c) : 0;
}
static int matchwhitespace(uint32_t c)
{
  return (c < 128) ? isspace((int)c) : 0;
}
static int matchalphanum(uint32_t c)
{
  return ((c == '_') || matchalpha(c) || matchdigit(c));
}
static int matchrange(uint32_t c, const uint32_t* str)
{
  return (    (c != '-')
           && (str[0] != 0)
           && (str[0] != '-')
           && (str[1] == '-')
           && (str[2] != 0)
           && (    (c >= str[0])
                && (c <= str[2])));
}
static int matchdot(uint32_t c)
{
#if defined(RE_DOT_MATCHES_NEWLINE) && (RE_DOT_MATCHES_NEWLINE == 1)
  (void)c;
  return 1;
#else
  return c != '\n' && c != '\r';
#endif
}
static int ismetachar(uint32_t c)
{
  return ((c == 's') || (c == 'S') || (c == 'w') || (c == 'W') || (c == 'd') || (c == 'D'));
}

static int matchmetachar(uint32_t c, const uint32_t* str)
{
  switch (str[0])
  {
    case 'd': return  matchdigit(c);
    case 'D': return !matchdigit(c);
    case 'w': return  matchalphanum(c);
    case 'W': return !matchalphanum(c);
    case 's': return  matchwhitespace(c);
    case 'S': return !matchwhitespace(c);
    default:  return (c == str[0]);
  }
}

static int matchcharclass(uint32_t c, const uint32_t* str)
{
  do
  {
    if (matchrange(c, str))
    {
      return 1;
    }
    else if (str[0] == '\\')
    {
      /* Escape-char: increment str-ptr and match on next char */
      str += 1;
      if (matchmetachar(c, str))
      {
        return 1;
      }
      else if ((c == str[0]) && !ismetachar(c))
      {
        return 1;
      }
    }
    else if (c == str[0])
    {
      if (c == '-')
      {
        return ((str[-1] == 0) || (str[1] == 0));
      }
      else
      {
        return 1;
      }
    }
  }
  while (*str++ != 0);

  return 0;
}

static int matchone(regex_t p, uint32_t c)
{
  switch (p.type)
  {
    case DOT:            return matchdot(c);
    case CHAR_CLASS:     return  matchcharclass(c, (const uint32_t*)p.u.ccl);
    case INV_CHAR_CLASS: return !matchcharclass(c, (const uint32_t*)p.u.ccl);
    case DIGIT:          return  matchdigit(c);
    case NOT_DIGIT:      return !matchdigit(c);
    case ALPHA:          return  matchalphanum(c);
    case NOT_ALPHA:      return !matchalphanum(c);
    case WHITESPACE:     return  matchwhitespace(c);
    case NOT_WHITESPACE: return !matchwhitespace(c);
    default:             return  (p.u.ch == c);
  }
}

static int matchstar(regex_t p, regex_t* pattern, const char* text, int* matchlength)
{
  int prelen = *matchlength;
  const char* prepoint = text;
  while (text[0] != '\0')
  {
    uint32_t cp = 0;
    int bytes = utf8_decode(text, &cp);
    if (!matchone(p, cp))
    {
      break;
    }
    text += bytes;
    (*matchlength) += bytes;
  }
  while (text >= prepoint)
  {
    if (matchpattern(pattern, text, matchlength))
      return 1;
    if (text == prepoint)
    {
      break;
    }
    {
      const char* prev = utf8_prev(prepoint, text);
      (*matchlength) -= (int)(text - prev);
      text = prev;
    }
  }

  *matchlength = prelen;
  return 0;
}

static int matchplus(regex_t p, regex_t* pattern, const char* text, int* matchlength)
{
  const char* prepoint = text;
  while (text[0] != '\0')
  {
    uint32_t cp = 0;
    int bytes = utf8_decode(text, &cp);
    if (!matchone(p, cp))
    {
      break;
    }
    text += bytes;
    (*matchlength) += bytes;
  }
  while (text > prepoint)
  {
    if (matchpattern(pattern, text, matchlength))
      return 1;
    {
      const char* prev = utf8_prev(prepoint, text);
      (*matchlength) -= (int)(text - prev);
      text = prev;
    }
  }

  return 0;
}

static int matchquestion(regex_t p, regex_t* pattern, const char* text, int* matchlength)
{
  if (p.type == UNUSED)
    return 1;
  if (matchpattern(pattern, text, matchlength))
      return 1;
  if (*text)
  {
    uint32_t cp = 0;
    int bytes = utf8_decode(text, &cp);
    if (matchone(p, cp))
    {
      const char* next = text + bytes;
      if (matchpattern(pattern, next, matchlength))
      {
        (*matchlength) += bytes;
        return 1;
      }
    }
  }
  return 0;
}


#if 0

/* Recursive matching */
static int matchpattern(regex_t* pattern, const char* text, int *matchlength)
{
  int pre = *matchlength;
  if ((pattern[0].type == UNUSED) || (pattern[1].type == QUESTIONMARK))
  {
    return matchquestion(pattern[1], &pattern[2], text, matchlength);
  }
  else if (pattern[1].type == STAR)
  {
    return matchstar(pattern[0], &pattern[2], text, matchlength);
  }
  else if (pattern[1].type == PLUS)
  {
    return matchplus(pattern[0], &pattern[2], text, matchlength);
  }
  else if ((pattern[0].type == END) && pattern[1].type == UNUSED)
  {
    return text[0] == '\0';
  }
  else if ((text[0] != '\0') && matchone(pattern[0], text[0]))
  {
    (*matchlength)++;
    return matchpattern(&pattern[1], text+1);
  }
  else
  {
    *matchlength = pre;
    return 0;
  }
}

#else

/* Iterative matching */
static int matchpattern(regex_t* pattern, const char* text, int* matchlength)
{
  int pre = *matchlength;
  for (;;)
  {
    if ((pattern[0].type == UNUSED) || (pattern[1].type == QUESTIONMARK))
    {
      return matchquestion(pattern[0], &pattern[2], text, matchlength);
    }
    else if (pattern[1].type == STAR)
    {
      return matchstar(pattern[0], &pattern[2], text, matchlength);
    }
    else if (pattern[1].type == PLUS)
    {
      return matchplus(pattern[0], &pattern[2], text, matchlength);
    }
    else if ((pattern[0].type == END) && pattern[1].type == UNUSED)
    {
      return (text[0] == '\0');
    }
/*  Branching is not working properly
    else if (pattern[1].type == BRANCH)
    {
      return (matchpattern(pattern, text) || matchpattern(&pattern[2], text));
    }
*/
    if (text[0] == '\0')
    {
      break;
    }
    uint32_t cp = 0;
    int bytes = utf8_decode(text, &cp);
    if (!matchone(*pattern, cp))
    {
      break;
    }
    pattern += 1;
    text += bytes;
    (*matchlength) += bytes;
  }

  *matchlength = pre;
  return 0;
}

#endif

/* UTF-8 helpers */
static int utf8_decode(const char* s, uint32_t* out)
{
  unsigned char c = (unsigned char)s[0];
  if (c < 0x80)
  {
    *out = c;
    return 1;
  }
  if ((c & 0xE0) == 0xC0)
  {
    unsigned char c1 = (unsigned char)s[1];
    if ((c1 & 0xC0) == 0x80)
    {
      *out = ((uint32_t)(c & 0x1F) << 6) | (uint32_t)(c1 & 0x3F);
      return 2;
    }
  }
  else if ((c & 0xF0) == 0xE0)
  {
    unsigned char c1 = (unsigned char)s[1];
    unsigned char c2 = (unsigned char)s[2];
    if (((c1 & 0xC0) == 0x80) && ((c2 & 0xC0) == 0x80))
    {
      *out = ((uint32_t)(c & 0x0F) << 12) | ((uint32_t)(c1 & 0x3F) << 6) | (uint32_t)(c2 & 0x3F);
      return 3;
    }
  }
  else if ((c & 0xF8) == 0xF0)
  {
    unsigned char c1 = (unsigned char)s[1];
    unsigned char c2 = (unsigned char)s[2];
    unsigned char c3 = (unsigned char)s[3];
    if (((c1 & 0xC0) == 0x80) && ((c2 & 0xC0) == 0x80) && ((c3 & 0xC0) == 0x80))
    {
      *out = ((uint32_t)(c & 0x07) << 18) | ((uint32_t)(c1 & 0x3F) << 12) | ((uint32_t)(c2 & 0x3F) << 6) | (uint32_t)(c3 & 0x3F);
      return 4;
    }
  }
  *out = c;
  return 1;
}

static const char* utf8_prev(const char* start, const char* cur)
{
  const char* p = cur;
  if (p <= start)
  {
    return start;
  }
  p -= 1;
  while (p > start && (((unsigned char)(*p) & 0xC0) == 0x80))
  {
    p -= 1;
  }
  return p;
}

static int utf8_encode(uint32_t cp, char out[5])
{
  if (cp <= 0x7F)
  {
    out[0] = (char)cp;
    out[1] = '\0';
    return 1;
  }
  if (cp <= 0x7FF)
  {
    out[0] = (char)(0xC0 | ((cp >> 6) & 0x1F));
    out[1] = (char)(0x80 | (cp & 0x3F));
    out[2] = '\0';
    return 2;
  }
  if (cp <= 0xFFFF)
  {
    out[0] = (char)(0xE0 | ((cp >> 12) & 0x0F));
    out[1] = (char)(0x80 | ((cp >> 6) & 0x3F));
    out[2] = (char)(0x80 | (cp & 0x3F));
    out[3] = '\0';
    return 3;
  }
  if (cp <= 0x10FFFF)
  {
    out[0] = (char)(0xF0 | ((cp >> 18) & 0x07));
    out[1] = (char)(0x80 | ((cp >> 12) & 0x3F));
    out[2] = (char)(0x80 | ((cp >> 6) & 0x3F));
    out[3] = (char)(0x80 | (cp & 0x3F));
    out[4] = '\0';
    return 4;
  }
  out[0] = '\0';
  return 0;
}

#endif /* TINY_REGEX_IMPLEMENTATION */

#endif /* DORA_TINY_REGEX_H */
