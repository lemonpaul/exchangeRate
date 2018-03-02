$(document).ready(function () {
    setInterval(refreshPartial, 10000)
});

function refreshPartial() {
  $.ajax({
    url: "welcome/show"
 })
}
