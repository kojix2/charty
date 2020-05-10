module Charty
  module Backends
    class GR
      Backends.register(:gr, self)

      attr_reader :context

      class << self
        def prepare
          require 'gr'
        end
      end

      def initialize; end

      def label(x, y); end

      attr_writer :series

      def render_layout(layout); end

      def render(context, filename); end

      def save; end

      def plot(plot, context)
        case context.method
        when :bar
        when :barth
        when :box_plot
        when :bubble
        when :curve
        when :scatter
        when :error_bar
        when :hist
        end
      end

      # ==== NEW PLOTTING API ====

      def begin_figure; end

      def bar; end

      def box_plot; end

      def set_xlabel(label); end

      def set_ylabel(label); end

      def set_xticks(values); end

      def set_xtic_labels(labels); end

      def set_xlim(min, max); end

      def disable_xaxis_grid; end

      def show; end
    end
  end
end
