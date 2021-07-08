module Charty
  module Plotters
    class DistributionPlotter < AbstractPlotter
      def flat_structure
        {
          x: :@values
        }
      end

      def wide_structure
        {
          x: :@values,
          color: :@columns
        }
      end

      def initialize(data:, variables:, **options, &block)
        x, y, color = variables.values_at(:x, :y, :color)
        super(x, y, color, data: data, **options, &block)

        setup_variables
      end

      attr_reader :weights

      def weights=(val)
        @weights = check_dimension(val, :weights)
      end

      attr_reader :variables

      attr_reader :color_norm

      def color_norm=(val)
        unless val.nil?
          raise NotImplementedError,
                "Specifying color_norm is not supported yet"
        end
      end

      attr_reader :legend

      def legend=(val)
        @legend = check_legend(val)
      end

      private def check_legend(val)
        check_boolean(val, :legend)
      end

      attr_reader :input_format, :plot_data, :variables, :var_types

      # This should be the same as one in RelationalPlotter
      # TODO: move this to AbstractPlotter and refactor with CategoricalPlotter
      private def setup_variables
        if x.nil? && y.nil?
          @input_format = :wide
          setup_variables_with_wide_form_dataset
        else
          @input_format = :long
          setup_variables_with_long_form_dataset
        end

        @var_types = @plot_data.columns.map { |k|
          [k, variable_type(@plot_data[k], :categorical)]
        }.to_h
      end

      private def setup_variables_with_wide_form_dataset
        unless color.nil?
          raise ArgumentError,
                "Unable to assign the following variables in wide-form data: color"
        end

        if data.nil? || data.empty?
          @plot_data = Charty::Table.new({})
          @variables = {}
          return
        end

        flat = data.is_a?(Charty::Vector)
        if flat
          @plot_data = {}
          @variables = {}

          [:x, :y].each do |var|
            case self.flat_structure[var]
            when :@index
              @plot_data[var] = data.index.to_a
              @variables[var] = data.index.name
            when :@values
              @plot_data[var] = data.to_a
              @variables[var] = data.name
            end
          end

          @plot_data = Charty::Table.new(@plot_data)
        else
          numeric_columns = @data.column_names.select do |cn|
            @data[cn].numeric?
          end
          wide_data = @data[numeric_columns]

          melt_params = {var_name: :@columns, value_name: :@values }
          if self.wide_structure.include?(:index)
            melt_params[:id_vars] = :@index
          end

          @plot_data = wide_data.melt(**melt_params)
          @variables = {}
          self.wide_structure.each do |var, attr|
            @plot_data[var] = @plot_data[attr]

            @variables[var] = case attr
                              when :@columns
                                wide_data.columns.name
                              when :@index
                                wide_data.index.name
                              else
                                nil
                              end
          end

          @plot_data = @plot_data[self.wide_structure.keys]
        end
      end

      private def setup_variables_with_long_form_dataset
        if data.nil? || data.empty?
          @plot_data = Charty::Table.new({})
          @variables = {}
          return
        end

        plot_data = {}
        variables = {}

        {
          x: self.x,
          y: self.y,
          color: self.color,
          weights: self.weights
        }.each do |key, val|
          next if val.nil?

          if data.column?(val)
            plot_data[key] = data[val]
            variables[key] = val
          else
            case val
            when Charty::Vector
              plot_data[key] = val
              variables[key] = val.name
            else
              raise ArgumentError,
                    "Could not interpret value %p for parameter %p" % [val, key]
            end
          end
        end

        @plot_data = Charty::Table.new(plot_data)
        @variables = variables.select do |var, name|
          @plot_data[var].notnull.any?
        end
      end

      private def map_color(palette: nil, order: nil, norm: nil)
        @color_mapper = ColorMapper.new(self, palette, order, norm)
      end

      private def map_size(sizes: nil, order: nil, norm: nil)
        @size_mapper = SizeMapper.new(self, sizes, order, norm)
      end

      private def map_style(markers: nil, dashes: nil, order: nil)
        @style_mapper = StyleMapper.new(self, markers, dashes, order)
      end
    end
  end
end
