class MediaController < ApplicationController
  getter media = Media.new

  before_action do
    only [:show, :edit, :update, :destroy] { set_media }
  end

  def index
    medias = Media.all
    respond_with do
      json medias.to_json
    end
  end

  def show
    respond_with do
      json media.to_json
    end
  end

  def create
    Factory::Media.new(media_params.validate!, params.files["file"])
      .build
      .bind(save_media)
      .fmap(handle_success(201))
      .value_or(handle_error)
  end

  def update
    media.set_attributes media_params.validate!
    if media.save
      respond_with do
        json media.to_json
      end
    else
      respond_with(403) do
        json({errors: "media.errors"}.to_json)
      end
    end
  end

  def destroy
    media.destroy
    respond_with(204) do
      json ""
    end
  end

  private def media_params
    params.validation do
      required :title
      required :kind
    end
  end

  private def set_media
    @media = Media.find! params[:id]
  end

  private def save_media
    ->(media : Media) do
      if media.save
        Monads::Right.new(media)
      else
        Monads::Left.new(media.errors.map { |error| {error.field.to_s => error.message.to_s} })
      end
    end
  end

  private def handle_success(code)
    ->(media : Media) do
      respond_with(code) do
        json media.to_json
      end
    end
  end
end