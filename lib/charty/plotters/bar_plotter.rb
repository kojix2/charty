require "enumerable/statistics"

module Charty
  module Plotters
    class BarPlotter < CategoricalPlotter
      def render
        backend = Backends.current
        backend.begin_figure
        draw_bars(backend)
        annotate_axes(backend)
        backend.show
      end

      private def draw_bars(backend)
        statistic = @plot_data.map(&:mean)
        bar_pos = (0 ... statistic.length).to_a
        backend.bar(bar_pos, statistic, color: @colors)
      end
    end
  end
end
