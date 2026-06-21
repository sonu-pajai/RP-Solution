class RpConsolidationOutputController < ApplicationController
  def index
    scope = RpConsolidation.includes(:rp_master, :reporting_entity, :period)
    scope = scope.where(reporting_entity_id: params[:reporting_entity_id]) if params[:reporting_entity_id].present?
    scope = scope.where(period_id: params[:period_id]) if params[:period_id].present?
    scope = scope.order(:created_at)

    @view_type = params[:view_type] || "list"

    case @view_type
    when "consolidated"
      grouped = scope.group_by { |rc| rc.rp_master_id }
      @consolidated_records = grouped.map do |_, records|
        from_dates = records.map(&:related_party_from).compact
        upto_dates = records.map(&:related_party_upto).compact
        {
          rp_master: records.first.rp_master,
          period: records.first.period,
          related_party_from: from_dates.min,
          related_party_upto: records.size > 1 ? upto_dates.max : nil,
          count: records.size
        }
      end
    when "standalone"
      @rp_consolidations = scope.to_a.map do |rc|
        grouped = scope.where(rp_master_id: rc.rp_master_id)
        first_from = grouped.first.related_party_from
        last_upto = grouped.count > 1 ? grouped.last.related_party_upto : nil
        rc.define_singleton_method(:first_from) { first_from }
        rc.define_singleton_method(:last_upto) { last_upto }
        rc
      end.uniq { |rc| rc.rp_master_id }
    else
      @rp_consolidations = scope
    end
  end
end
