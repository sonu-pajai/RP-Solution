class RelationshipsController < ApplicationController
  load_and_authorize_resource except: [:bulk_upload, :template]

  def index
    @relationships = Relationship.order(:category, :name).page(params[:page])
  end

  def new
    @relationship = Relationship.new
  end

  def create
    @relationship = Relationship.new(relationship_params)
    if @relationship.save
      redirect_to relationships_path, notice: "Relationship created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @relationship = Relationship.find(params[:id])
  end

  def update
    @relationship = Relationship.find(params[:id])
    if @relationship.update(relationship_params)
      redirect_to relationships_path, notice: "Relationship updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy
    redirect_to relationships_path, notice: "Relationship deleted."
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to bulk_upload_relationships_path, alert: "Please select a file."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        rel = Relationship.new(name: row["Relationship"]&.strip, category: row["Category"]&.strip)
        rel.save ? count += 1 : (errors << "Row #{line}: #{rel.errors.full_messages.join(', ')}")
      end

      if errors.empty?
        redirect_to relationships_path, notice: "#{count} records uploaded."
      else
        redirect_to bulk_upload_relationships_path, alert: "#{count} created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    csv_data = CSV.generate { |csv| csv << ["Relationship", "Category"] }
    send_data csv_data, filename: "relationships_template.csv", type: "text/csv"
  end

  private

  def relationship_params
    params.require(:relationship).permit(:name, :category)
  end
end
