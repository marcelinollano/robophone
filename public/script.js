// script.js

function deleteItem(url, callback) {
  console.log(url + "?token=" + envToken);
  const r = new XMLHttpRequest();
  r.open("DELETE", url + "?token=" + envToken, true);
  r.onreadystatechange = function() {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
}

const deleteLinks = document.getElementsByClassName("delete");

for (let i = deleteLinks.length - 1; i >= 0; i--) {
  deleteLinks[i].addEventListener(
    "click",
    function(e) {
      const link = this;
      const url = this.href;
      deleteItem(url, function(res) {
        if (res == "true") {
          link.closest("tr").classList.toggle("is-marked");
          setTimeout(function() {
            link.closest("tr").classList.toggle("is-deleted");
          }, 400);
        }
      });
      e.preventDefault();
    },
    false
  );
}

const phones = document.getElementsByClassName("phone");
for (let i = 0; i < phones.length; i++) {
  text = phones[i].innerHTML;
  text = text.replace(/\d{6}$/, "******");
  phones[i].innerHTML = text;
}
