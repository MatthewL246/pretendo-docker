---
sidebar_position: 1
---

# Computer browser

1. Start a web browser using `127.0.0.1:8080` as a proxy server. For example, use
   `chrome.exe --proxy-server="127.0.0.1:8080"` or the Firefox network settings page.
   - I don't recommend using the same browser as the one you use for normal web browsing because you will get a lot of
     irrelevant noise in the mitmproxy logs. Consider downloading [Chrome Beta](https://www.google.com/chrome/beta/) or
     [Firefox Beta](https://www.mozilla.org/en-US/firefox/channel/desktop/) to have an isolated browser for this.
   - If you don't want to deal with the security warnings on every page from being MITMed, go to
     [mitm.it](http://mitm.it) in your proxied browser and follow the instructions there to trust the mitmproxy
     certificate. This is secure because mitmproxy generates a random certificate on first run, so nobody else could
     MITM your traffic except you.
2. Open [pretendo.network/account](https://pretendo.network/account) in your proxied browser. **Make sure that there is
   a big red banner stating "This is an unofficial Pretendo Network server!"** If there is not, your proxy settings did
   not apply correctly. Then, once you have verified this, sign up for an account there, just as you would on the
   official Pretendo Network servers.
   - Ignore the captcha, it's disabled in the account server.
3. You can visit [juxt.pretendo.network](https://juxt.pretendo.network) in your proxied browser to view Juxt posts.

## Changing which server you are connected to

- To connect to your selfhosted Pretendo server, create a shortcut to your web browser with the proxy settings and use
  that to open the Pretendo Network website.
- To connect to the official Pretendo servers, use your regular web browser without the proxy settings.
