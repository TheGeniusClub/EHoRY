# https://github.com/tiann/KernelSU/blob/main/scripts/ksubot.py
# https://github.com/SukiSU-Ultra/SukiSU-Ultra/blob/main/scripts/ksubot.py
import asyncio
import os
import sys
from telethon import TelegramClient

API_ID = 611335
API_HASH = "d524b414d21f4d37f08684c1df41ac9c"

BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")
MESSAGE_THREAD_ID = os.environ.get("MESSAGE_THREAD_ID")
RUN_URL = os.environ.get("RUN_URL")
TIME = os.environ.get("NTIME")
REPOSITORY = os.environ.get("REPOSITORY")
AUTHOR = os.environ.get("AUTHOR")
COMMIT_MESSAGE = os.environ.get("COMMIT_MESSAGE", "")
COMMIT_URL = os.environ.get("COMMIT_URL", "")

if COMMIT_MESSAGE:
    first_line = COMMIT_MESSAGE.split('\n')[0]
    if len(first_line) > 256:
        first_line = first_line[:253] + '...'
    commit_message = f'```\n{first_line.strip()}\n```'
else:
    commit_message = ''

if COMMIT_URL:
    commit_line = f'[Commit]({COMMIT_URL})\n'
else:
    commit_line = ''

MSG_TEMPLATE = """
**✅ Script is built!**

📦 Repository: {repository}
💬 Commit: {commit_message}
👤 Author: {author}
⏰ Time: {time}

{commit_url}[Workflow run]({run_url})
""".strip()

def get_caption():
    msg = MSG_TEMPLATE.format(
        repository=REPOSITORY or "Unknown Repository",
        commit_message=commit_message,
        author=AUTHOR or "Unknown",
        commit_url=commit_line,
        run_url=RUN_URL,
        time=TIME or "Unknown",
    )
    if len(msg) > 1024:
        return RUN_URL
    return msg

def check_environ():
    global CHAT_ID, MESSAGE_THREAD_ID
    
    required_vars = {
        "BOT_TOKEN": BOT_TOKEN,
        "CHAT_ID": CHAT_ID,
        "RUN_URL": RUN_URL
    }
    
    for var_name, var_value in required_vars.items():
        if var_value is None:
            print(f"[-] Invalid {var_name}")
            exit(1)
    
    try:
        CHAT_ID = int(CHAT_ID)
    except (ValueError, TypeError):
        print("[-] Invalid CHAT_ID format")
        exit(1)
    
    if MESSAGE_THREAD_ID is not None and MESSAGE_THREAD_ID != "":
        try:
            MESSAGE_THREAD_ID = int(MESSAGE_THREAD_ID)
        except (ValueError, TypeError):
            print("[-] Invalid MESSAGE_THREAD_ID format")
            exit(1)
    else:
        MESSAGE_THREAD_ID = None

async def main():
    print("[+] Starting Telegram upload process")
    check_environ()
    
    files = sys.argv[1:]
    print(f"[+] Files to upload: {files}")
    
    if len(files) <= 0:
        print("[-] No files to upload")
        exit(1)
    
    print("[+] Logging in to Telegram with bot")
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    session_dir = os.path.join(script_dir, "ksubot")
    
    try:
        async with await TelegramClient(
            session=session_dir, 
            api_id=API_ID, 
            api_hash=API_HASH
        ).start(bot_token=BOT_TOKEN) as bot:
            
            caption = [""] * len(files)
            final_caption = get_caption()
            caption[-1] = final_caption
            
            print("[+] Caption content:")
            print("---")
            print(final_caption)
            print("---")
            
            print("[+] Sending files to Telegram")
            await bot.send_file(
                entity=CHAT_ID, 
                file=files, 
                caption=caption, 
                reply_to=MESSAGE_THREAD_ID, 
                parse_mode="markdown"
            )
            print("[+] Upload completed successfully!")
            
    except Exception as e:
        print(f"[-] Telegram API error: {e}")
        exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[-] Operation cancelled by user")
    except Exception as e:
        print(f"[-] An unexpected error occurred: {e}")
        exit(1)