module ApplicationHelper
  def custom_bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = "success" if type == "notice"
      type = "error" if type == "alert"
      text = "<script>toastr.#{type}('#{message}');</script>"
      flash_messages << text.html_safe if message
    end
    flash_messages.join("\n").html_safe
  end

  def percent_calculator(value1, value2)
    percent = (value2 * 100) / value1
    if percent.nan?
      return number_to_percentage(0, precision: 0)
    else
      return number_to_percentage(percent, precision: 0)
    end
  end
end
