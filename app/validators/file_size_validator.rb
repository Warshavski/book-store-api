# frozen_string_literal: true

# FileSizeValidator
#
#   Used to validate uploaded file size
#
class FileSizeValidator < ActiveModel::EachValidator

  class Helper
    include Singleton
    include ActionView::Helpers::NumberHelper
  end

  MESSAGES  = { is: :wrong_size, minimum: :size_too_small, maximum: :size_too_big }.freeze
  CHECKS    = { is: :==, minimum: :>=, maximum: :<= }.freeze

  DEFAULT_TOKENIZER = lambda { |value| value.split(//) }
  RESERVED_OPTIONS  = %i[minimum maximum within is tokenizer too_short too_long].freeze

  def initialize(options)
    range = (options.delete(:in) || options.delete(:within))

    if range
      raise ArgumentError, ':in and :within must be a Range' unless range.is_a?(Range)

      options[:minimum] = range.begin
      options[:maximum] = range.end
      options[:maximum] -= 1 if range.exclude_end?
    end

    super
  end

  def check_validity!
    keys = CHECKS.keys & options.keys

    if keys.empty?
      raise ArgumentError, 'Range unspecified. Specify the :within, :maximum, :minimum, or :is option.'
    end

    keys.each do |key|
      value = options[key]
      raise ArgumentError, ":#{key} must be a non-negative Integer or symbol" unless valid_value?(value)
    end
  end

  def validate_each(record, attribute, value)
    validate_uploader!(value)

    value = (options[:tokenizer] || DEFAULT_TOKENIZER).call(value) if value.kind_of?(String)

    CHECKS.each do |key, validity_check|
      check_value = options[key]
      next unless check_value

      value ||= [] if key == :maximum

      value_size = value.size
      next if value_size.send(validity_check, check_value)

      errors_options = options.except(*RESERVED_OPTIONS)
      errors_options[:file_size] = help.number_to_human_size check_value

      default_message = options[MESSAGES[key]]
      errors_options[:message] ||= default_message if default_message

      record.errors.add(attribute, MESSAGES[key], errors_options)
    end
  end

  def help
    Helper.instance
  end

  private

  def valid_value?(value)
    value.is_a?(Integer) && value >= 0
  end

  def validate_uploader!(uploader)
    unless uploader.kind_of?(CarrierWave::Uploader::Base)
      raise(ArgumentError, 'A CarrierWave::Uploader::Base object was expected')
    end
  end
end
