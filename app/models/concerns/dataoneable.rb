module Dataoneable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, work, options={})
      return result if result[:error]

      extra = get_extra(result)
      total = get_sum(extra, "total")

      { events: {
          source: name,
          work: work.pid,
          total: total,
          extra: extra,
          months: get_events_by_month(extra) } }
    end

    def get_extra(result)
      counts = result.deep_fetch("facet_counts", "facet_ranges", "dateLogged", "counts") { [] }
      counts.each_slice(2).map do |item|
        year, month = *get_year_month(item.first)

        { "month" => month,
          "year" => year,
          "total" => item.last }
      end
    end

    def get_events_by_month(extra)
      extra.map do |month|
        { month: month["month"].to_i,
          year: month["year"].to_i,
          total: month["total"].to_i }
      end
    end

    def config_fields
      [:url]
    end

    def url
      "https://cn.dataone.org/cn/v1/query/logsolr/select?"
    end

    def cron_line
      config.cron_line || "* 4 * * *"
    end

    def queue
      config.queue || "high"
    end
  end
end
