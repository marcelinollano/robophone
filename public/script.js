// script.js

// Delete resoruces

const deleteResourceRequest = function(url, callback) {
  const r = new XMLHttpRequest();
  r.open("DELETE", url + "?token=" + envToken, true);
  r.onreadystatechange = function() {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
};

const deleteResourceEvents = function(links) {
  for (let i = links.length - 1; i >= 0; i--) {
    links[i].addEventListener(
      "click",
      function(e) {
        const link = this;
        const url = this.href;
        deleteResourceRequest(url, function(res) {
          if (res == "true") {
            const table = document.querySelectorAll("table")[0];
            if (table.querySelectorAll("tr").length == 2) {
              table.remove();
              const main = document.querySelectorAll("main")[0];
              const p = document.createElement("P");
              p.innerHTML = "Nothing to see here yet.";
              main.appendChild(p);
            } else {
              link.closest("tr").remove();
            }
          }
        });
        e.preventDefault();
      },
      false
    );
  }
};

deleteResourceEvents(document.querySelectorAll("table .delete"));

// Mask phones

const maskPhones = function(phones) {
  for (let i = 0; i < phones.length; i++) {
    text = phones[i].innerHTML;
    text = text.replace(/\d{6}$/, "******");
    phones[i].innerHTML = text;
  }
};

maskPhones(document.getElementsByClassName("phone"));

// const addList = document.querySelectorAll(".list .add");
//
// for (let i = 0; i < addList.length; i++) {
//   addList[i].addEventListener("click", function(e) {
//     const item = addList[i].closest("ol > li");
//     const dup = item.cloneNode(true);
//     item.after(dup);
//     e.preventDefault;
//   });
// }

// http://localhost:5000/faye -d 'message={"channel":"/messages", "data": "hello", "ext": {"token": TOKEN}}'
//
// const client = new Faye.Client("http://localhost:5000/faye");
//
// const subscription = client.subscribe("/messages", function(data) {
//   alert(data);
//   location.reload();
// });
//
// subscription.then(function() {
//   console.log("Subscription is now active!");
// });
