class Rpt01Controller < ApplicationController
  def index
    all_periods = Period.order(:id)

    # Current quarter: last 3 periods by id
    current_quarter_periods = all_periods.last(3)
    # Last 4 quarters = last 12 periods (or all if fewer)
    display_periods = all_periods.last(12)

    @periods = display_periods
    @period_months = display_periods.map(&:month)

    txns = RpTransaction.includes(:reporting_entity, :reporting_unit, :period)
                        .where(period_id: display_periods.map(&:id))

    # Build pivot: group key -> { period_month -> amount }
    pivot = {}
    txns.each do |t|
      key = [
        t.reporting_entity.name,
        t.reporting_unit.name,
        t.transaction_type,
        t.counterparty,
        t.sub_nature
      ]
      pivot[key] ||= {}
      pivot[key][t.period.month] ||= 0
      pivot[key][t.period.month] += t.amount.to_f
    end

    @rows = pivot.map do |key, amounts|
      {
        reporting_entity:  key[0],
        reporting_unit:    key[1],
        transaction_type:  key[2],
        counterparty:      key[3],
        sub_nature:        key[4],
        amounts:           amounts
      }
    end

    # Quarter totals per row
    cq_months = current_quarter_periods.map(&:month)
    @rows.each do |row|
      row[:current_quarter_total] = cq_months.sum { |m| row[:amounts][m].to_f }
      row[:grand_total] = @period_months.sum { |m| row[:amounts][m].to_f }
    end
  end
end
