require "json"
require "colorize"

private class AssetManifestBuilder
  MAX_RETRIES =   20
  RETRY_AFTER = 0.25

  property retries
  @retries : Int32 = 0
  @manifest_path : String = File.expand_path("./public/mix-manifest.json")

  def initialize
  end

  def initialize(@manifest_path)
  end

  def build_with_retry
    if manifest_exists?
      build
    else
      retry_or_raise_error
    end
  end

  private def retry_or_raise_error
    if retries < MAX_RETRIES
      self.retries += 1
      sleep(RETRY_AFTER)
      build_with_retry
    else
      raise_missing_manifest_error
    end
  end

  private def build
    manifest_file = File.read(@manifest_path)
    manifest = JSON.parse(manifest_file)

    manifest.as_h.each do |key, value|
      key = key.gsub(/^\//, "").gsub(/^assets\//, "")
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{key}"] = "#{value.as_s}" %})
    end
  end

  private def manifest_exists?
    File.exists?(@manifest_path)
  end

  private def raise_missing_manifest_error
    puts "Manifest at #{@manifest_path} does not exist".colorize(:red)
    puts "Make sure you have compiled your assets".colorize(:red)
  end
end

begin
  manifest_path = ARGV[0]

  builder = if manifest_path.blank?
              AssetManifestBuilder.new
            else
              AssetManifestBuilder.new(manifest_path)
            end

  builder.build_with_retry
rescue ex
  puts ex.message.colorize(:red)
  raise ex
end
