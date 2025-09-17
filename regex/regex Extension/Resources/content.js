(function() {
   // Helper to compile safe regex objects from pattern strings.
   function compilePatterns(patternList) {
     const compiled = [];
     for (const p of patternList) {
       try {
         // If user wants flags, allow syntax like /pattern/gi
         if (p.startsWith('/') && p.lastIndexOf('/') > 0) {
           const lastSlash = p.lastIndexOf('/');
           const pattern = p.slice(1, lastSlash);
           const flags = p.slice(lastSlash + 1);
           compiled.push(new RegExp(pattern, flags));
         } else {
           // plain string -> treat as substring or as escaped regex
           compiled.push(new RegExp(p));
         }
       } catch (e) {
         // Ignore invalid patterns so they don't break the script
         console.warn('Invalid regex in RegexBlocker extension:', p, e);
       }
     }
     return compiled;
   }

   // Replace the page with a blocking message
   function showBlockedNotice(reason) {
     try {
       // Clear the document content early:
       document.documentElement.innerHTML = '';
       document.open();
       document.write(`
         <!doctype html>
         <html>
         <head>
           <meta charset="utf-8">
           <title>Blocked by RegexBlocker</title>
           <meta name="viewport" content="width=device-width,initial-scale=1">
           <style>
             body{font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                  display:flex; align-items:center; justify-content:center; height:100vh; margin:0;
                  background:#f8fafc; color:#111;}
             .card{max-width:520px; padding:28px; border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,0.08);
                   text-align:center; background:white;}
             h1{margin:0 0 8px 0; font-size:20px;}
             p{margin:0; color:#444;}
             .small{margin-top:10px; font-size:12px; color:#888;}
           </style>
         </head>
         <body>
           <div class="card">
             <h1>Page blocked</h1>
             <p>This page was blocked by your RegexBlocker extension.</p>
             <div class="small">${reason ? 'Rule: ' + reason : ''}</div>
           </div>
         </body>
         </html>`);
       document.close();
     } catch (e) {
       // last resort: navigate to about:blank
       try { window.location.replace('about:blank'); } catch (_) {}
     }
   }

   // Main entry
    browser.runtime.sendMessage({action: "getPatterns"}).then((response) => {
        console.log(response);
        if (response && response.patterns) {
            const regexes = compilePatterns(response.patterns);
            const url = window.location.href;
            
            for (const r of regexes) {
                try {
                    if (r.test(url)) {
                        // Send reason optionally to showBlockedNotice
                        showBlockedNotice(r.toString());
                        break;
                    }
                } catch (e) {
                    console.warn('RegexBlocker match failed', e);
                }
            }
        }
    });
    /*
    browser.runtime.sendMessage({name: "getPatterns"}).then(response => {
        console.log("test2");
        console.log(response);
     
   });
     */
 })();
