module WithingsAPIOAuth2
  class Client

    # @return [Hash] Weight measurements of given date
    def weight_logs(date = Date.today)
      measure_logs(date, 1)
    end

    # @return [Hash] Fat free mass measurements of given date
    def fat_free_mass_logs(date = Date.today)
      measure_logs(date, 5)
    end

    # @return [Hash] Fat ratio measurements of given date
    def fat_ratio_logs(date = Date.today)
      measure_logs(date, 6)
    end

    # @return [Hash] Fat mass measurements of given date
    def fat_mass_logs(date = Date.today)
      measure_logs(date, 8)
    end

    # @return [Hash] Body temperature measurements of given date
    def body_temp_logs(date = Date.today)
      measure_logs(date, 71)
    end

    def measure_logs(date = Date.today, meastype = nil)
      get("/measure?action=getmeas&category=1&startdate=#{date.to_time.to_i}&enddate=#{((date + 1.day).to_time.to_i - 1)}&meastype=#{meastype}")
    end
  end
end
