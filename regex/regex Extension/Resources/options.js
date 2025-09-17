// options.js
const ta = document.getElementById('patterns');
const status = document.getElementById('status');
const saveBtn = document.getElementById('save');
const clearBtn = document.getElementById('clear');

function load() {
    browser.runtime.sendMessage({action: "getPasswordSaved"}).then(response => {
        console.log(response);
        if (response && response.passwordSaved) {
            console.log(response);
            lock();
        }else{
            browser.runtime.sendMessage({action: "getPatterns"}).then(response => {
                if (response && response.patterns) {
                    ta.value = response.patterns.join('\n');
                }
            });
        }
    });
}

function lock() {
  document.body.innerHTML = `
    <div class="card">
      <h1>Page Locked</h1>
      <p>This page is locked because you set up a password in the app. 
         It will be unlocked after you remove the password.</p>
      <p class="small">RegexBlocker</p>
    </div>
  `;

  // Apply styles inline instead of re-writing <head>
  document.body.style.cssText = `
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    display:flex; align-items:center; justify-content:center; height:100vh; margin:0;
    background:#f8fafc; color:#111;
  `;

  const card = document.querySelector(".card");
  card.style.cssText = `
    max-width:520px; padding:28px; border-radius:12px;
    box-shadow:0 6px 18px rgba(0,0,0,0.08);
    text-align:center; background:white;
  `;
}


function save() {
    console.log("save");
  const lines = ta.value.split('\n').map(l => l.trim()).filter(Boolean);
    console.log(lines);
  browser.runtime.sendMessage({action: "savePatterns", patterns: lines}).then( () => {
    status.textContent = 'Saved';
    setTimeout(() => status.textContent = '', 1500);
  });
}

function clearAll() {
    console.log("clear");
  ta.value = '';
  browser.runtime.sendMessage({action: "savePatterns", patterns: []}).then( () => {
    status.textContent = 'Cleared';
    setTimeout(() => status.textContent = '', 1500);
  });
}

saveBtn.addEventListener('click', save);
clearBtn.addEventListener('click', clearAll);
document.addEventListener('DOMContentLoaded', load);
