class StandardFormBuilder < ActionView::Helpers::FormBuilder
  def error_messages
    return unless object.respond_to?(:errors) && object.errors.any?

    errors_list = ""
    errors_list << @template.content_tag(:h3, "There were errors saving this #{object.class.name.underscore.humanize.downcase}.", :class => "errorExplanation")
    errors_list << object.errors.full_messages.map { |message| @template.content_tag(:li, message.html_safe) }.join("\n")

    @template.content_tag(:ul, errors_list.html_safe)
  end
end