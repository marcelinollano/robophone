// script.js

// Delete resoruces

const deleteResource = function(url, callback) {
  const r = new XMLHttpRequest();
  r.open("DELETE", url + "?token=" + envToken, true);
  r.onreadystatechange = function() {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
};

const deleteResourceEvents = function(links) {
  links.forEach(function(link) {
    link.addEventListener(
      "click",
      function(e) {
        const link = this;
        const url = this.href;
        deleteResource(url, function(res) {
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
  });
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

// Add list items

const addListItem = function(link) {
  const listItem = link.closest("ol > li");
  const listItemCopy = listItem.cloneNode(true);
  const hiddenInput = listItemCopy.querySelectorAll('input[type="hidden"]')[0];
  hiddenInput.value = "";
  const select = listItemCopy.querySelectorAll("select")[0];
  const options = select.querySelectorAll("option");
  options.forEach(function(option) {
    option.selected = false;
  });
  const addLink = listItemCopy.querySelectorAll(".add")[0];
  const deleteLink = listItemCopy.querySelectorAll(".delete")[0];
  addListItemEvent(addLink);
  deleteListItemEvent(deleteLink);
  listItem.after(listItemCopy);
};

const addListItemEvent = function(link) {
  link.addEventListener("click", function(e) {
    addListItem(link);
    e.preventDefault;
  });
};

const addListItemLinks = document.querySelectorAll(".list .add");

addListItemLinks.forEach(function(link) {
  addListItemEvent(link);
});

// Delete list items

const checkVisible = function(elements) {
  let count = 0;
  elements.forEach(function(element) {
    if (element.style.display !== "none") {
      count += 1;
    }
  });
  return count;
};

const deleteListItemEvent = function(link) {
  link.addEventListener("click", function(e) {
    const listItem = link.closest(".list > li");
    const list = link.closest(".list");
    const listItems = list.querySelectorAll("ol > li");
    if (checkVisible(listItems) > 1) {
      const options = listItem.querySelectorAll("option");
      options.forEach(function(option) {
        option.selected = false;
      });
      listItem.style.display = "none";
    }
    e.preventDefault;
  });
};

const deleteListItemLinks = document.querySelectorAll(".list .delete");

deleteListItemLinks.forEach(function(link) {
  deleteListItemEvent(link);
});

// Faye

// http://localhost:5000/faye \
// -d 'message={"channel":"/messages", "data": "hello", "ext": {"token": TOKEN}}'
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
