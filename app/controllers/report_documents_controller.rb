class ReportDocumentsController < ApplicationController
  def index
    @documents = ReportDocument.order(created_at: :desc).page(params[:page])
  end

  def new
    @document = ReportDocument.new(
      reporting_entity_id: params[:reporting_entity_id],
      period_id: params[:period_id]
    )
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
  end

  def create
    @document = ReportDocument.new(document_params)
    @document.created_by = current_user
    if @document.save
      redirect_to report_documents_path, notice: "Document saved."
    else
      @reporting_entities = ReportingEntity.all
      @periods = Period.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @document = ReportDocument.find(params[:id])
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
  end

  def update
    @document = ReportDocument.find(params[:id])
    if @document.update(document_params)
      redirect_to report_documents_path, notice: "Document updated."
    else
      @reporting_entities = ReportingEntity.all
      @periods = Period.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document = ReportDocument.find(params[:id])
    @document.destroy
    redirect_to report_documents_path, notice: "Document deleted."
  end

  def download
    @document = ReportDocument.find(params[:id])
    format_type = params[:format_type] || "docx"
    content = replace_variables(@document.content, @document)

    case format_type
    when "pdf"
      html = render_to_string(template: "report_documents/pdf_view", layout: "report_pdf", locals: { document: @document, resolved_content: content })
      pdf = Grover.new(html, format: "A4", margin: { top: "1cm", bottom: "1cm", left: "1cm", right: "1cm" }).to_pdf
      send_data pdf, filename: "#{@document.title.parameterize}.pdf", type: "application/pdf"
    else
      docx = html_to_docx(@document.title, content)
      send_data docx, filename: "#{@document.title.parameterize}.docx",
        type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    end
  end

  def insert_data
    entity = ReportingEntity.find_by(id: params[:reporting_entity_id])
    period = Period.find_by(id: params[:period_id])
    section = params[:section]

    html = case section
    when "consolidation"
      records = RpConsolidation.includes(:rp_master).where(reporting_entity_id: entity&.id, period_id: period&.id).order(:created_at)
      render_to_string(partial: "report_documents/data_consolidation", locals: { records: records })
    when "transactions"
      records = RpTransaction.where(reporting_entity_id: entity&.id, period_id: period&.id).order(:created_at)
      render_to_string(partial: "report_documents/data_transactions", locals: { records: records })
    when "rp_list"
      records = RpMaster.where(active: true).order(:name)
      render_to_string(partial: "report_documents/data_rp_list", locals: { records: records })
    else
      ""
    end

    render json: { html: html }
  end

  private

  def document_params
    params.require(:report_document).permit(:title, :content, :reporting_entity_id, :period_id)
  end

  def replace_variables(content, document)
    entity = document.reporting_entity
    period = document.period
    txns = RpTransaction.where(reporting_entity_id: entity&.id, period_id: period&.id)

    variables = {
      "entity_name" => entity&.name || "—",
      "period" => period&.month || "—",
      "financial_year" => period&.financial_year || "—",
      "today" => Date.today.strftime("%d-%b-%Y"),
      "prepared_by" => current_user&.name || current_user&.email || "—",
      "total_rp_count" => RpMaster.where(active: true).count.to_s,
      "total_txn_count" => txns.count.to_s,
      "total_txn_amount" => txns.sum(:amount).to_s
    }

    result = content.to_s
    variables.each do |key, value|
      result = result.gsub(/\{\{\s*#{key}\s*\}\}/, value)
    end
    # Strip the styled span wrappers around variables
    result.gsub(/<span[^>]*>([^<]*)<\/span>/) do |match|
      inner = $1
      if inner.match?(/\{\{.*\}\}/)
        inner
      else
        match
      end
    end
  end

  def html_to_docx(title, html)
    require "nokogiri"
    doc = Nokogiri::HTML.fragment(html)

    Caracal::Document.render do |docx|
      docx.h1 title
      docx.p ""

      doc.children.each do |node|
        case node.name
        when "h1"
          docx.h1 node.text.strip
        when "h2"
          docx.h2 node.text.strip
        when "h3"
          docx.h3 node.text.strip
        when "table"
          rows = []
          node.css("tr").each do |tr|
            rows << tr.css("th, td").map { |cell| cell.text.strip }
          end
          docx.table rows do
            border_color "000000"
            border_line :single
            border_size 4
          end if rows.any?
        when "ul"
          node.css("li").each { |li| docx.ul { li li.text.strip } }
        when "ol"
          node.css("li").each { |li| docx.ol { li li.text.strip } }
        when "p", "div"
          text = node.text.strip
          docx.p text if text.present?
        when "br"
          docx.p ""
        when "text"
          docx.p node.text.strip if node.text.strip.present?
        end
      end
    end
  end
end
