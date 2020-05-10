module Charty
  module Backends
    class GR
      Backends.register(:gr, self)

      attr_reader :context

      class << self
        def prepare
          require 'gr/plot'
        end
      end

      def initialize
        @GR = ::GR
      end

      def label(x, y); end

      attr_writer :series

      def render_layout(layout); end

      def render(context, _filename)
        plot(context)
      end

      def save; end

      def plot(context)
        case context.method
        when :bar
          if context.series.size > 1
            raise "I'm sorry. Bar charts for multiple series are not yet possible."
          end

          @GR.barplot(context.series[0].xs, context.series[0].ys,
                      title: context.title,
                      xlabel: context.xlabel,
                      ylabel: context.ylabel)
        when :barth
        when :box_plot
        when :bubble
        when :curve
          @GR.plot(*context.series.map { |i| [i.xs, i.ys] },
                   title: context.title,
                   xlabel: context.xlabel,
                   ylabel: context.ylabel,
                   labels: context.series.map(&:label))
        when :scatter
          @GR.scatter(*context.series.map { |i| [i.xs, i.ys] },
                      title: context.title,
                      xlabel: context.xlabel,
                      ylabel: context.ylabel)
        when :error_bar
        when :hist
          if context.data.size > 1
            if context.data.first.is_a? Array
              raise "I'm sorry. Bar charts for multiple series are not yet possible."
            end
          end
          @GR.histogram(context.data,
                        title: context.title,
                        xlabel: context.xlabel,
                        ylabel: context.ylabel)
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
