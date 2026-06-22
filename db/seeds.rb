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

# Transactions
transactions_data = [
  ["RPT Asset","Advance Recoverable","Sales Advance","Receivables","Receivables","Receivables"],
  ["RPT Asset","Advance Recoverable","Vendor Advance","Receivables","Receivables","Receivables"],
  ["RPT Asset","Fixed Deposit","Short-term Deposit","Deposits placed","Deposits placed","Deposits placed"],
  ["RPT Asset","Investment","Equity Investment","Investment","Investment","Investment"],
  ["RPT Asset","Lease Receivable","Office Lease Liability","Receivables","Receivables","Receivables"],
  ["RPT Asset","Loan Given","Short-term Loan","Lending","Lending","Lending"],
  ["RPT Asset","Loan Given","Working Capital Facility","Advances","Advances","Advances"],
  ["RPT Asset","Loan Given","Working Capital Loan","Advances","Advances","Advances"],
  ["RPT Asset","Outstanding Income","Consultancy Payable","Receivables","Receivables","Receivables"],
  ["RPT Asset","Receivable","Trade Payable","Receivables","Receivables","Receivables"],
  ["RPT Asset","Receivable","Trade Receivable","Receivables","Receivables","Receivables"],
  ["RPT Asset","Security Deposit","Lease Deposit","Deposits placed","Deposits placed","Deposits placed"],
  ["RPT Expense","Bank Charges","Processing Fees","Fees paid","Fees paid","Fees paid"],
  ["RPT Expense","Business Support","Operational Support","Common resoruce expenses","Common resoruce expenses","Common resoruce expenses"],
  ["RPT Expense","Commission Expense","Distribution Support","Fees paid","Fees paid","Fees paid"],
  ["RPT Expense","Cost Allocation","Shared Cost Allocation","Common resoruce expenses","Common resoruce expenses","Common resoruce expenses"],
  ["RPT Expense","Employee Cost Recharge","Shared Services","Expenses for service received","Expenses for service received","Expenses for service received"],
  ["RPT Expense","Insurance Recovery","Life Insurance","Insurance premium paid","Insurance premium paid","Insurance premium paid"],
  ["RPT Expense","Interest Expense","Bank Deposit Interest","Intereste expense","Intereste expense","Intereste expense"],
  ["RPT Expense","Interest Expense","Intercorporate Deposit","Intereste expense","Intereste expense","Intereste expense"],
  ["RPT Expense","IT Support Expense","ERP Maintenance","Common resoruce expenses","Common resoruce expenses","Common resoruce expenses"],
  ["RPT Expense","Professional Fees","Consulting Charges","Expenses for service received","Expenses for service received","Expenses for service received"],
  ["RPT Expense","Purchase of Goods","Food Products","Purchase of Goods","Purchase of Goods","Purchase of Goods"],
  ["RPT Expense","Purchase of Goods","Raw Materials","Purchase of Goods","Purchase of Goods","Purchase of Goods"],
  ["RPT Expense","Referal Payout","AUM referal","Fees paid","Fees paid","Fees paid"],
  ["RPT Expense","Rent Expense","Office Lease","Rent Expense","Rent Expense","Rent Expense"],
  ["RPT Expense","Rent Expense","Warehouse Lease","Rent Expense","Rent Expense","Rent Expense"],
  ["RPT Expense","Secondment","Employee Secondment","Common resoruce expenses","Common resoruce expenses","Common resoruce expenses"],
  ["RPT Expense","Service Expense","Management Services","Expenses for service received","Expenses for service received","Expenses for service received"],
  ["RPT Income","Bank Charge Recovery","Processing Fees","Income from services rendered","Income from services rendered","Income from services rendered"],
  ["RPT Income","Brand Usage Income","Trademark Usage","Royalty earned","Royalty earned","Royalty earned"],
  ["RPT Income","Business Support Recovery","Operational Support","Common resoruce Income","Common resoruce Income","Common resoruce Income"],
  ["RPT Income","Commission Income","Distribution Support","Fees received","Fees received","Fees received"],
  ["RPT Income","Cost Allocation Recovery","Shared Cost Allocation","Common resoruce Income","Common resoruce Income","Common resoruce Income"],
  ["RPT Income","Employee Cost Recovery","Shared Services","Common resoruce Income","Common resoruce Income","Common resoruce Income"],
  ["RPT Income","Insurance Premium","Life Insurance","Insurance Premium Earned","Insurance Premium Earned","Insurance Premium Earned"],
  ["RPT Income","Interest Income","Bank Deposit Interest","Interest Income","Interest Income","Interest Income"],
  ["RPT Income","Interest Income","Intercorporate Deposit","Interest Income","Interest Income","Interest Income"],
  ["RPT Income","IT Support Recovery","ERP Maintenance","Common resoruce Income","Common resoruce Income","Common resoruce Income"],
  ["RPT Income","Professional Charges","Consulting Charges","Income from services rendered","Income from services rendered","Income from services rendered"],
  ["RPT Income","Referal Income","AUM referal","Fees paid","Fees paid","Fees paid"],
  ["RPT Income","Rent Income","Office Lease","Rent Income","Rent Income","Rent Income"],
  ["RPT Income","Rental Income","Warehouse Lease","Rental Income","Rental Income","Rental Income"],
  ["RPT Income","Sale of Goods","Food Products","Sale of Goods","Sale of Goods","Sale of Goods"],
  ["RPT Income","Sale of Goods","Raw Materials","Sale of Goods","Sale of Goods","Sale of Goods"],
  ["RPT Income","Secondment Recovery","Employee Secondment","Common resoruce Income","Common resoruce Income","Common resoruce Income"],
  ["RPT Income","Service Income","Management Services","Income from services rendered","Income from services rendered","Income from services rendered"],
  ["RPT Income","Telecom Employee Benefits","Bank Guarantee","Income from services rendered","Income from services rendered","Income from services rendered"],
  ["RPT Income","Telecom Income","Bank Guarantee","Income from services rendered","Income from services rendered","Income from services rendered"],
  ["RPT Liability","Advance from Customer","Sales Advance","Payables","Payables","Payables"],
  ["RPT Liability","Capital outstanding","Equity Investment","Investment by RPs","Investment by RPs","Investment by RPs"],
  ["RPT Liability","Fixed Deposit Liability","Short-term Deposit","Deposits accepted","Deposits accepted","Deposits accepted"],
  ["RPT Liability","Investment Liability","Equity Investment","Investment by RPs","Investment by RPs","Investment by RPs"],
  ["RPT Liability","Lease Liability","Office Lease Liability","Payables","Payables","Payables"],
  ["RPT Liability","Loan Taken","Short-term Loan","Borrowings","Borrowings","Borrowings"],
  ["RPT Liability","Loan Taken","Working Capital Facility","Borrowings","Borrowings","Borrowings"],
  ["RPT Liability","Loan Taken","Working Capital Loan","Borrowings","Borrowings","Borrowings"],
  ["RPT Liability","Outstanding Expense","Consultancy Payable","Payables","Payables","Payables"],
  ["RPT Liability","Payable","Trade Payable","Payables","Payables","Payables"],
  ["RPT Liability","Payable","Trade Receivable","Payables","Payables","Payables"],
  ["RPT Liability","Payable","Vendor Advance","Payables","Payables","Payables"],
  ["RPT Liability","Security Deposit Payable","Lease Deposit","Deposits accepted","Deposits accepted","Deposits accepted"],
  ["RPT volume/others","Bonds issued","Bank Guarantee","Bonds Issued","Bonds Issued","Bonds Issued"],
  ["RPT volume/others","Bonds Subscribed","Bank Guarantee","Bonds Subscribed","Bonds Subscribed","Bonds Subscribed"],
  ["RPT volume/others","Brand Usage Recovery","Trademark Usage","Royalty paid","Royalty paid","Royalty paid"],
  ["RPT volume/others","Corporate Guarantee given","Bank Guarantee","Guarantee given","Guarantee given","Guarantee given"],
  ["RPT volume/others","Corporate Guarantee taken","Bank Guarantee","Guarantee received","Guarantee received","Guarantee received"],
  ["RPT volume/others","Guarantee given","Corporate Guarantee","Guarantee given","Guarantee given","Guarantee given"],
  ["RPT volume/others","Guarantee taken","Corporate Guarantee","Guarantee received","Guarantee received","Guarantee received"],
  ["RPT volume/others","Purchase of Assets","Home Loan","Purchase of Assets","Purchase of Assets","Purchase of Assets"],
  ["RPT volume/others","Sale of Assets","Home Loan","Sale of Assets","Sale of Assets","Sale of Assets"]
]
transactions_data.each do |row|
  Transaction.find_or_create_by!(nature: row[0], transaction_type: row[1], sub_type: row[2]) do |t|
    t.as18 = row[3]
    t.acb = row[4]
    t.sebi = row[5]
  end
end

# RP Master records
admin = User.find_by(email: "admin@mintifi.com")
[
  { entity: "AD Group", salutation: "Mr.", name: "Rahul Sharma", pan: "ABCDE1234F", category: "Director/KMP", specific_relationship: "Managing Director", dob: "1980-05-15", related_to_director: true, sebi: true, ca: true, as18: true, ind_as24: true, active: true },
  { entity: "AD Group", salutation: "Mrs.", name: "Priya Sharma", pan: "FGHIJ5678K", category: "Relatives of KMP", specific_relationship: "Spouse", dob: "1983-08-22", related_to_director: false, sebi: true, ca: true, as18: false, ind_as24: true, active: true },
  { entity: "Vertex Healthcare Pvt Ltd", salutation: "M/s", name: "Zenith Infra Pvt Ltd", pan: "LMNOP9012Q", category: "Subsidiary", specific_relationship: "Subsidiary Company", dob: "2010-03-01", related_to_director: false, sebi: true, ca: true, as18: true, ind_as24: true, active: true },
  { entity: "Vertex Healthcare Pvt Ltd", salutation: "Mr.", name: "Amit Verma", pan: "RSTUV3456W", category: "Director/KMP", specific_relationship: "CFO", dob: "1975-11-10", related_to_director: true, sebi: true, ca: true, as18: true, ind_as24: true, active: true },
  { entity: "Crystal Packaging Pvt Ltd", salutation: "Dr.", name: "Suresh Patel", pan: "WXYZA7890B", category: "Entity Controlled by KMP / Director", specific_relationship: "Entity Controlled by KMP / Director", dob: "1968-02-28", related_to_director: true, sebi: true, ca: true, as18: true, ind_as24: true, active: true },
  { entity: "Crystal Packaging Pvt Ltd", salutation: "Ms.", name: "Neha Gupta", pan: "CDEFG1234H", category: "Relatives of KMP", specific_relationship: "Daughter", dob: "1995-07-19", related_to_director: false, sebi: false, ca: true, as18: false, ind_as24: true, active: false }
].each do |data|
  entity = ReportingEntity.find_by(name: data[:entity])
  RpMaster.find_or_create_by!(name: data[:name], reporting_entity: entity) do |rp|
    rp.salutation = data[:salutation]
    rp.pan = data[:pan]
    rp.category = data[:category]
    rp.specific_relationship = data[:specific_relationship]
    rp.dob_or_incorporation = data[:dob]
    rp.related_to_director = data[:related_to_director]
    rp.related_party_sebi = data[:sebi]
    rp.related_party_companies_act = data[:ca]
    rp.related_party_as18 = data[:as18]
    rp.related_party_ind_as24 = data[:ind_as24]
    rp.active = data[:active]
    rp.created_by = admin
  end
end

puts "Seeded successfully!"
