class LocationsController < ApplicationController
  # before_action :authenticate_user!, only: [:new, :edit, :update, :destroy] #devise authorization
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    # forcastStart = DateTime.now.days_ago(120)
    # forcastEnd = DateTime.now.days_ago(99)
    
    # #from start to end
    # @forcast = Array.new(24, Prediction.new)

    # hourStart = forcastStart
    # hourEnd = hourStart + 2000.hours


    # @hourPredictions = Prediction.all

    Chartkick.options = {
      library: {interpolateNulls:true}
    }

    @stationData = @location.getStationHash
    @station = Location.getNearestStation(@location, @stationData)

    @weatherJSON = @location.getWeatherHash
    @stationWind = Location.getWeatherAtStation(@station, @weatherJSON)

    @surfaceWind = Location.surfaceWeather(@location.lat, @location.lng)["channel"]["wind"]
    @surfaceAtmo = Location.surfaceWeather(@location.lat, @location.lng)["channel"]["atmosphere"]
    @surfaceCondition = Location.surfaceWeather(@location.lat, @location.lng)["channel"]["item"]["condition"]
    
    # @sufaceWind = Location.surfaceWeather(@location.lat, @location.lng)["channel"]["wind"]
    # @sufaceAtmosphere = Location.surfaceWeather(@location.lat, @location.lng)["channel"]["atmosphere"]


    # @stationLabel = {}
    @stationBearing = {"0" => @surfaceWind["direction"]}
    @stationSpeed = {"0" => @surfaceWind["speed"]}
    @stationTemp = {"0" => @surfaceCondition["temp"]}
    @stationWind.each do |altitude, data|
      @stationBearing[altitude] = data["bearing"]
      @stationSpeed[altitude] = data["speed"]
      @stationTemp[altitude] = data["temp"]
    end


    @windData = {
      "bearing" => @stationBearing, 
      "speed" => @stationSpeed,
      "temp" => @stationTemp
    }


    # @predictionTimeline = [
    #   ["label", start, fin],["label", start, fin],["label", start, fin]
    # ]
     @predictionTimeline = []
     @location.predictions.each do |p| 
        @predictionTimeline.push([p.user.email.to_s, p.start.to_s, p.end.to_s])
     end

    # @stationJSON
  end#show

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name)
    end
end
