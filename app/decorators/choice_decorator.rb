class ChoiceDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def to_percentage
    percentage = (object.popularity * 100).round(1)
    precision = if (object.popularity * 100).to_i == percentage
                  0
                else
                  1
                end
    number_to_percentage(percentage, precision: precision)
  end
end
