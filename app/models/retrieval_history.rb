class RetrievalHistory < ActiveRecord::Base
  belongs_to :retrieval_status

  SUCCESS_MSG = "SUCCESS"
  SUCCESS_NODATA_MSG = "SUCCESS WITH NO DATA"
  ERROR_MSG = "ERROR"
  SKIPPED_MSG = "SKIPPED"
  SOURCE_DISABLED = "Source disabled"
  SOURCE_NOT_ACTIVE = "Source not active"

  def to_included_json
    {
        :updated_at => retrieved_at.to_time,
        :count => event_count
    }
  end

end
