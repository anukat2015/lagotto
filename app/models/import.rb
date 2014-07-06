# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Import
  # include HTTP request helpers
  include Networkable

  attr_accessor :filter, :sample, :rows

  def initialize(options = {})
    from_index_date = options.fetch(:from_index_date, Date.yesterday.to_s(:db))
    until_index_date = options.fetch(:until_index_date, Date.yesterday.to_s(:db))
    type = options.fetch(:type, 'journal-article')
    member = options.fetch(:member, nil)
    issn = options.fetch(:issn, nil)

    @filter = "from-index-date:#{from_index_date}"
    @filter += ",until-index-date:#{until_index_date}"
    @filter += ",type:#{type}"
    @filter += ",member:#{member}" if member
    @filter += ",issn:#{issn}" if issn
    @sample = options.fetch(:sample, nil)
    @rows = options.fetch(:rows, 1000)
  end

  def total_results(options={})
    result = get_result(query_url(offset = 0, rows = 0), options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
    result.deep_fetch('message', 'total-results') { 0 }
  end

  def queue_article_import
    if @sample
      delay(priority: 0, queue: "article-import-queue").process_data
    else
      (0...total_results).step(@rows) do |offset|
        delay(priority: 0, queue: "article-import-queue").process_data(offset)
      end
    end
  end

  def process_data(offset = 0)
    result = get_data(offset)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def query_url(offset = 0, rows = @rows)
    url = "http://api.crossref.org/works?"
    if @sample
      params = { filter: @filter, sample: @sample }
    else
      params = { filter: @filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    result = get_result(query_url(offset), options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result)
    # return early if an error occured
    return result if result["status"] != "ok"

    items = result['message'] && result.deep_fetch('message', 'items') { nil }
    Array(items).map do |item|
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      { doi: item["DOI"],
        title: item["title"][0],
        year: year,
        month: month,
        day: day }
    end
  end

  def import_data(items)
    Array(items).map do |item|
      article = Article.find_or_create(item)
      article ? article.id : nil
    end
  end

  def to_hash
    { filter: filter,
      rows: rows,
      offset: offset,
      sample: sample }
  end
end