$("body").on("click", "tr[data-href]", function (e) {
  // console.log($(e.target).parent());
  if (
    !$(e.target).parent().is("td") &&
    !$(e.target).parent().is("a") &&
    !$(e.target).parent().is("div") &&
    !$(e.target).parent().is("button")
  ) {
    Rails.ajax({
      url: $(this).data("href"),
      type: "get",
      data: "",
      success: function (data) {},
      error: function (data) {},
    });
  }
});
