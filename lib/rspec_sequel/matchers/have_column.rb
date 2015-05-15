module RspecSequel
  module Matchers

    class HaveColumnMatcher < RspecSequel::Base
      def description
        desc = "have a column #{@attribute.inspect}"
        desc << " with type: '#{@options[:type]}'" if @options[:type]
        desc << " and max_length: #{@options[:max_length]}" if @options[:max_length]
        desc << " and default: '#{@options[:default]}'" if @options[:default]
        desc
      end

      def valid?(db, i, c, attribute, options)

        # check column existance
        col = db.schema(c.table_name).detect{|col| col[0]==attribute}
        matching = !col.nil?

        # bail out if no such column
        unless matching
          @suffix << "but no such column exists"
          return false
        end

        # check type
        if @options[:type]
          expected = db.send(:type_literal, {:type => options[:type]}).to_s
          if matching
            found = [col[1][:type].to_s, col[1][:db_type].to_s]
            @suffix << "but found: { type: '#{col[1][:type]}', db_type: '#{col[1][:db_type]}',"
            matching &&= found.include?(expected)
          end
        end

        # check max_length
        if @options[:max_length]
          expected = (col[1][:max_length] == options[:max_length])
          unless expected
            @suffix << "max_length: '#{col[1][:max_length].to_s}',"
            matching &&= false
          end
        end

        # check default
        if @options[:default]
          expected = (col[1][:default] == options[:default])
          unless expected
            @suffix << "default: '#{col[1][:default].to_s}',"
            matching &&= false
          end
        end

        unless @suffix.empty?
          @suffix.last.sub!(/,$/,'') # remove last ,
          @suffix << '}' # close found list
        end
        matching
      end
    end

    def have_column(*args)
      HaveColumnMatcher.new(*args)
    end

  end
end