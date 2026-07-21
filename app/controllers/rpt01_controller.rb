class Rpt01Controller < ApplicationController
  MONTH_TO_QUARTER = {
    "April" => 1, "May" => 1, "June" => 1,
    "July" => 2, "August" => 2, "September" => 2,
    "October" => 3, "November" => 3, "December" => 3,
    "January" => 4, "February" => 4, "March" => 4
  }.freeze

  QUARTER_LABEL = { 1 => "Jun", 2 => "Sep", 3 => "Dec", 4 => "Mar" }.freeze
  QUARTER_MONTHS = {
    1 => [4, 5, 6], 2 => [7, 8, 9], 3 => [10, 11, 12], 4 => [1, 2, 3]
  }.freeze

  def index
    all_periods = Period.where.not(month_number: nil).order(:financial_year, :month_number)
    @all_periods = all_periods
    @selected_period_id = params[:period_id].present? ? params[:period_id].to_i : all_periods.last&.id

    selected_period = all_periods.find { |p| p.id == @selected_period_id } || all_periods.last
    return @quarter_cols = [] unless selected_period

    month_name = selected_period.month.to_s.split("-").first
    current_q  = MONTH_TO_QUARTER[month_name] || 4
    fy_parts   = selected_period.financial_year.to_s.split("-")
    fy_start   = fy_parts[0].to_i

    # Generate last 5 quarters ending at selected period's quarter
    @quarter_cols = []
    q = current_q
    fy = fy_start
    5.times do
      end_month_num = QUARTER_MONTHS[q].last
      end_year = end_month_num >= 4 ? fy : fy + 1
      label = "#{QUARTER_LABEL[q]}-#{end_year.to_s.slice(-2, 2)}"
      period_ids = all_periods.select { |p| QUARTER_MONTHS[q].include?(p.month_number.to_i) && p.financial_year == "#{fy}-#{fy+1}" }.map(&:id)
      @quarter_cols.unshift({ key: "#{fy}-#{fy+1}-Q#{q}", label: label, period_ids: period_ids })
      q -= 1
      if q == 0
        q = 4
        fy -= 1
      end
    end

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
    end.sort_by { |r| [r[:reporting_entity], r[:reporting_unit], r[:transaction_type]] }

    @rows_by_entity = @rows.group_by { |r| r[:reporting_entity] }
  end
end
