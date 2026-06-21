# Users
User.find_or_create_by!(email: "admin@mintifi.com") do |u|
  u.password = "password123"
  u.name = "Admin"
  u.role = "admin"
end

# Reporting Entities & Units
{
  "AD Group" => ["Infrastructure Division", "Finance", "Retail Division"],
  "Vertex Healthcare Pvt Ltd" => ["Finance", "Retail Division", "HR"],
  "Crystal Packaging Pvt Ltd" => ["Infra", "Operations", "Finance"]
}.each do |entity_name, units|
  entity = ReportingEntity.find_or_create_by!(name: entity_name)
  units.each { |u| entity.reporting_units.find_or_create_by!(name: u) }
end

# Relationships
{
  "Self" => ["Self"],
  "Subsidiary" => ["Subsidiary Company"],
  "Associate/Joint Venture" => ["Associate Company", "Joint Venture"],
  "Entity Controlled by KMP / Director" => ["Entity Controlled by KMP / Director", "Fellow Subsidiary", "Private Company where Director is Director & Member", "Public Company where Director along with relatives holds >2%"],
  "KMP related" => ["LLP where Director/KMP has Significant Influence"],
  "Holding Company" => ["Holding Company"],
  "Investing Company" => ["Investing Company"],
  "Director/KMP" => ["Indepedent Director", "Managing Director", "CFO", "CS"],
  "Relatives of KMP" => ["Spouse", "Father", "Mother", "Brother", "Sister", "Son", "Daughter"]
}.each do |cat, rels|
  rels.each { |r| Relationship.find_or_create_by!(name: r, category: cat) }
end

# Periods
%w[Apr-25 May-25 Jun-25 Jul-25 Aug-25 Sep-25 Oct-25 Nov-25 Dec-25 Jan-26 Feb-26 Mar-26].each do |m|
  Period.find_or_create_by!(month: m, financial_year: "2025-2026")
end

puts "Seeded successfully!"
