class ReportsController < ApplicationController
  before_filter :load_paths, :except => [:show_filtered, :find_report_filter]

  def new
    @report = Report.new

    @report_items = ["summary", "product", "management", "marketing", "business_development", "competition", "sales", "finance", "legal", "other"]

    @report_months = [[0,"JAN"], [1, "FEB"], [2, "MAR"], [3, "APR"], [4, "MAY"], [5, "JUN"], [6, "JUL"], [7, "AUG"], [8, "SEP"], [9, "OCT"], [10, "NOV"], [11, "DEC"]]
  end

  def create
    @report = @company.reports.new(params[:report])
    if @report.save
      redirect_to organization_fund_company_report_path(@organization, @fund, @company, @report), :flash => {:success => "Report created"}
    else
      render :new
    end      
  end

  def index
    @reports = @company.reports.all
    session[:report_year] = Date.today.beginning_of_year
  end

  def show    
    @report_items = ["summary", "product", "management", "marketing", "business_development", "competition", "sales", "finance", "legal", "other"]
    @report = @company.reports.find(params[:id])

    @report_months = [[0,"JAN"], [1, "FEB"], [2, "MAR"], [3, "APR"], [4, "MAY"], [5, "JUN"], [6, "JUL"], [7, "AUG"], [8, "SEP"], [9, "OCT"], [10, "NOV"], [11, "DEC"]]
  end

  def show_filtered

    @report_items = ["summary", "product", "management", "marketing", "business_development", "competition", "sales", "finance", "legal", "other"]
    
    @organization = Organization.first
    @fund = Fund.first
    @company = Company.first
    
    @report = @company.reports.where("period = ?", Date.civil(params[:date][:report_year].to_i, params[:date][:report_month].to_i, 1)).first

    render :update do |page|
      page.replace_html :report_holder, :partial => "report_content"
      page << "recolor_month(#{params[:date][:report_month].to_i - 1})"
    end    
  end

  def find_report_filter
    year = Date.civil(params[:fyear].to_i)

    starting = year.beginning_of_year
    ending = year.end_of_year
    
    @filtered_reports = Report.where('period between ? AND ?', starting, ending).all.map {|report| [report.period.strftime("%B"), report.id] }
    
    render(:json => @filtered_reports)   

  end

  def change_report_period
    if params[:report_move_direction] == '1'
      session[:report_year] -= 1.year
    else
      session[:report_year] += 1.year
    end

    report_start = session[:report_year].beginning_of_year
    report_end = session[:report_year].end_of_year
    new_report = Report.where('period between ? AND ?', report_start, report_end).last
    
    new_report ||= params[:id]
    new_report ||= params[:report_id]

    redirect_to :action => :show, :organization_id => params[:organization_id], :fund_id => params[:fund_id], :company_id => params[:company_id], :id => new_report

  end

  def edit
    @report = @company.reports.find(params[:id])
  end
  
  def update
    @report = @company.reports.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html { redirect_to organization_fund_company_report_path(@organization, @fund, @company, @report), :flash => {:success => "Report updated"} }
        format.js
      else
        render :edit
      end
    end
  end

  private
    def load_paths
      @organization = Organization.find(params[:organization_id])
      @fund = @organization.funds.find(params[:fund_id])      
      @company = @fund.companies.find(params[:company_id])
    end

end
