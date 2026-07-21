class Rpt01Controller < ApplicationController
  MONTH_TO_QUARTER = {
    "April" => "Q1", "May" => "Q1", "June" => "Q1",
    "July" => "Q2", "August" => "Q2", "September" => "Q2",
    "October" => "Q3", "November" => "Q3", "December" => "Q3",
    "January" => "Q4", "February" => "Q4", "March" => "Q4"
  }.freeze

  QUARTER_END_MONTH = {
    "Q1" => "June", "Q2" => "September", "Q3" => "December", "Q4" => "March"
  }.freeze

  def index
    all_periods = Period.where.not(month_number: nil).order(:financial_year, :month_number)
    @all_periods = all_periods
    @selected_period_id = params[:period_id].present? ? params[:period_id].to_i : all_periods.last&.id

    # Group into quarters: key = "FY-Q", value = array of periods
    quarters = {}
    all_periods.each do |p|
      month_name = p.month.to_s.split("-").first
      q = MONTH_TO_QUARTER[month_name]
      next unless q
      key = "#{p.financial_year}-#{q}"
      quarters[key] ||= []
      quarters[key] << p
    end

    # Build quarter list, representative period = end-of-quarter month
    quarter_list = quarters.map do |key, periods|
      fy, q = key.split("-Q")
      end_month = QUARTER_END_MONTH["Q#{q}"]
      rep = periods.find { |p| p.month.to_s.start_with?(end_month) } || periods.last
      { key: key, label: rep.month, period_ids: periods.map(&:id), rep_period: rep }
    end.sort_by { |q| [q[:rep_period].financial_year.to_s, q[:rep_period].month_number.to_i] }

    # Find quarter of selected period — this becomes the LAST (current) quarter
    selected_period = all_periods.find { |p| p.id == @selected_period_id }
    if selected_period
      month_name = selected_period.month.to_s.split("-").first
      q = MONTH_TO_QUARTER[month_name]
      selected_qkey = "#{selected_period.financial_year}-#{q}"
      idx = quarter_list.index { |qp| qp[:key] == selected_qkey } || (quarter_list.size - 1)
    else
      idx = quarter_list.size - 1
    end

    # Show 5 quarters: 4 before + selected as current (last)
    @quarter_cols = quarter_list[[idx - 4, 0].max..idx]

    all_period_ids = @quarter_cols.flat_map { |q| q[:period_ids] }

    txns = RpTransaction.includes(:reporting_entity, :reporting_unit, :period)
                        .where(period_id: all_period_ids)

    pivot = {}
    txns.each do |t|
      key = [
        t.reporting_entity.name,
        t.reporting_unit.name,
        t.transaction_type,
        t.counterparty,
        t.sub_nature
      ]
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
