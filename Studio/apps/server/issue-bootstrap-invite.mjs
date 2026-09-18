import {openAccountStore} from './account-store.mjs';
import {openLoginStore} from './login-store.mjs';
const path=process.env.STUDIO_DB_PATH;if(!path)throw new Error('Missing STUDIO_DB_PATH');
const accounts=openAccountStore(path),login=openLoginStore(path);
try{
  if(accounts.list({limit:1}).items.length)throw new Error('Bootstrap invitation is only available before the first account');
  const result=login.issueInvite({administrator:true});
  process.stdout.write(`First administrator invitation (shown once): ${result.code}\nExpires: ${new Date(result.expiresAt).toISOString()}\n`);
}finally{login.close();accounts.close();}
