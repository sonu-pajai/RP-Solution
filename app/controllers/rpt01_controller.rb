class Rpt01Controller < ApplicationController
  QUARTER_END_MONTHS = {
    "Q1" => "Jun",   # Apr, May, Jun  -> Jun
    "Q2" => "Sep",   # Jul, Aug, Sep  -> Sep
    "Q3" => "Dec",   # Oct, Nov, Dec  -> Dec
    "Q4" => "Mar"    # Jan, Feb, Mar  -> Mar
  }.freeze

  MONTH_TO_QUARTER = {
    "Apr" => "Q1", "May" => "Q1", "Jun" => "Q1",
    "Jul" => "Q2", "Aug" => "Q2", "Sep" => "Q2",
    "Oct" => "Q3", "Nov" => "Q3", "Dec" => "Q3",
    "Jan" => "Q4", "Feb" => "Q4", "Mar" => "Q4"
  }.freeze

  def index
    all_periods = Period.order(:financial_year, :id)
    @all_periods = all_periods
    @selected_period_id = params[:period_id].present? ? params[:period_id].to_i : all_periods.last&.id

    # Group periods by financial_year + quarter, pick last month period of each quarter
    quarters = {}
    all_periods.each do |p|
      short_month = p.month.split("-").first
      q = MONTH_TO_QUARTER[short_month]
      next unless q
      key = "#{p.financial_year}-#{q}"
      quarters[key] ||= []
      quarters[key] << p
    end

    quarter_periods = quarters.map do |key, periods|
      end_month_prefix = QUARTER_END_MONTHS[key.split("-").last]
      rep = periods.find { |p| p.month.start_with?(end_month_prefix) } || periods.last
      { key: key, label: rep.month, period_ids: periods.map(&:id), rep_period: rep }
    end.sort_by { |q| q[:rep_period].id }

    # Find the quarter of the selected period
    selected_period = all_periods.find { |p| p.id == @selected_period_id }
    if selected_period
      short_month = selected_period.month.split("-").first
      q = MONTH_TO_QUARTER[short_month]
      selected_qkey = "#{selected_period.financial_year}-#{q}"
      idx = quarter_periods.index { |qp| qp[:key] == selected_qkey } || (quarter_periods.size - 1)
    else
      idx = quarter_periods.size - 1
    end

    # Current quarter (selected) + last 4 quarters before it = 5 total
    @quarter_cols = quarter_periods[[idx - 4, 0].max..idx]

    all_period_ids = @quarter_cols.flat_map { |q| q[:period_ids] }

    txns = RpTransaction.includes(:reporting_entity, :reporting_unit, :period)
                        .where(period_id: all_period_ids)

    # Build pivot: group key -> { quarter_key -> sum of amount }
    pivot = {}
    txns.each do |t|
      key = [
        t.reporting_entity.name,
        t.reporting_unit.name,
        t.transaction_type,
        t.counterparty,
        t.sub_nature
      ]
      # Find which quarter this period belongs to
      qcol = @quarter_cols.find { |q| q[:period_ids].include?(t.period_id) }
      next unless qcol
      pivot[key] ||= {}
      pivot[key][qcol[:key]] ||= 0
      pivot[key][qcol[:key]] += t.amount.to_f
    end

    @rows = pivot.map do |key, amounts|
      {
        reporting_entity: key[0],
        reporting_unit:   key[1],
        transaction_type: key[2],
        counterparty:     key[3],
        sub_nature:       key[4],
        amounts:          amounts,
        total:            amounts.values.sum
      }
    end
  end
end
