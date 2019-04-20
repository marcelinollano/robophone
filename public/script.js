// script.js

function deleteItem(url, callback) {
  console.log(url + "?token=" + envToken);
  var r = new XMLHttpRequest();
  r.open("DELETE", url + "?token=" + envToken, true);
  r.onreadystatechange = function() {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
}

var deleteLinks = document.getElementsByClassName("delete");

for (var i = deleteLinks.length - 1; i >= 0; i--) {
  deleteLinks[i].addEventListener(
    "click",
    function(e) {
      var link = this;
      var url = this.href;
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
