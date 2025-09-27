// background.js
console.log("Background worker started");

window.addEventListener("unhandledrejection", event => {
  console.error("Unhandled rejection:", event.reason);
});
window.addEventListener("error", event => {
  console.error("Background error:", event.error);
});

browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log(message);
    if (message.action == "getPatterns") {
        browser.runtime.sendNativeMessage({
            action: "getPatterns"
        }).then((response) => {
            console.log(response);
            if (response.success && response.eventName == "getResponse"){
                sendResponse(response);
            }else{
                console.log("Getting patterns failed.");
                sendResponse(null);
            }
        }).catch((error) => {
            console.error(error)
            sendResponse(null);
        });
    }else if (message.action == "savePatterns") {
        browser.runtime.sendNativeMessage({
            action: "savePatterns",
            patterns: message.patterns
        }).then((response) => {
            console.log(response);
            if (response.success && response.eventName == "saveResponse"){
                sendResponse(response);
            }else{
                console.log("Saving patterns failed.");
                sendResponse(null);
            }
        }).catch((error) => {
            console.error(error)
            sendResponse(null);
        });
    }else if (message.action == "getPasswordSaved"){
        browser.runtime.sendNativeMessage({
            action: "getPasswordSaved"
        }).then((response) => {
            console.log(response);
            if (response.success && response.eventName == "passwordResponse"){
                sendResponse(response);
            }else{
                console.log("Getting password status failed.");
                sendResponse(null);
            }
        }).catch((error) => {
            console.error(error)
            sendResponse(null);
        });
    }
    return true;
});

