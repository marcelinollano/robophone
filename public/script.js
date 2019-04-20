function deleteStory(url, callback) {
  var r = new XMLHttpRequest();
  r.open(
    "DELETE",
    envUrl + "/story?token=" + envToken + "&permalink=" + permalink,
    true
  );
  r.onreadystatechange = function() {
    if (r.readyState != 4 || r.status != 200) return;
    callback(r.responseText);
  };
  r.send();
}

var storysDeleteLinks = document.getElementsByClassName("story-delete");
for (var i = storysDeleteLinks.length - 1; i >= 0; i--) {
  storysDeleteLinks[i].addEventListener(
    "click",
    function(e) {
      var link = this;
      var url = link.href;
      deleteStory(url, function(res) {
        if (res == "true") {
          link.parentNode.classList.toggle("is-marked");
          setTimeout(function() {
            link.parentNode.classList.toggle("is-deleted");
          }, 500);
        }
      });
      e.preventDefault();
    },
    false
  );
}
