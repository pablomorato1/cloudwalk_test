class HomeController < ApplicationController

  def index
  end

  def process_log
    return if params[:log_file].nil?
    report_service = GameReportService.new({ log_file: params[:log_file].tempfile.read })
    @games = report_service.process

    render "index"
  end
end
