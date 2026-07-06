class ReportsController < ApplicationController
  def index
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
  end

  def generate
    @reporting_entity = ReportingEntity.find(params[:reporting_entity_id])
    @period = Period.find(params[:period_id])
    format = params[:format_type] || "docx"

    consolidations = RpConsolidation.includes(:rp_master)
      .where(reporting_entity_id: @reporting_entity.id, period_id: @period.id)
      .order(:created_at)

    transactions = RpTransaction.includes(:reporting_unit)
      .where(reporting_entity_id: @reporting_entity.id, period_id: @period.id)
      .order(:created_at)

    case format
    when "pdf"
      html = render_to_string(template: "reports/report", layout: "report_pdf", locals: {
        reporting_entity: @reporting_entity, period: @period,
        consolidations: consolidations, transactions: transactions
      })
      pdf = Grover.new(html, format: "A4", margin: { top: "1cm", bottom: "1cm", left: "1cm", right: "1cm" }).to_pdf
      send_data pdf, filename: report_filename("pdf"), type: "application/pdf"
    else
      docx = generate_docx(@reporting_entity, @period, consolidations, transactions)
      send_data docx, filename: report_filename("docx"), type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    end
  end

  private

  def report_filename(ext)
    "RPT_Report_#{@reporting_entity.name.parameterize}_#{@period.month}_#{Date.today}.#{ext}"
  end

  def generate_docx(entity, period, consolidations, transactions)
    Caracal::Document.render do |docx|
      docx.h1 "Related Party Transaction Report"
      docx.h2 "#{entity.name} — #{period.month} #{period.financial_year}"
      docx.p ""

      # Consolidation section
      docx.h3 "RP List Consolidation"
      if consolidations.any?
        docx.table [["Unique Code", "Name", "Category", "From", "Upto", "Custom Input"]] +
          consolidations.map { |c|
            [c.rp_master.unique_code, c.rp_master.name, c.rp_master.category,
             c.related_party_from.to_s, c.related_party_upto.to_s, c.custom_input.to_s]
          } do
          border_color "000000"
          border_line :single
          border_size 4
        end
      else
        docx.p "No consolidation records found."
      end

      docx.p ""
      docx.h3 "RP Transactions"
      if transactions.any?
        docx.table [["Counterparty", "Nature", "Sub-Nature", "Type", "Amount"]] +
          transactions.map { |t|
            [t.counterparty, t.nature, t.sub_nature, t.transaction_type, t.amount.to_s]
          } do
          border_color "000000"
          border_line :single
          border_size 4
        end
      else
        docx.p "No transactions found."
      end
    end
  end
end
