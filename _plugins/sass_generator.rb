module Jekyll
	require 'sass'
	class SassGenerator < Generator
		safe true
		priority :low

		def generate(site)
			begin
        main_file_path = "./assets/stylesheets/main.css"

        if File.exists? main_file_path
          return nil if (Time.now.to_i - File.mtime(main_file_path).to_i) < 3
        end

        t = Time.now.strftime("%Y-%m-%d %H:%M:%S");
        puts "[#{t}] Performing Sass Conversion."
        sass_filename = "./_assets/stylesheets/main.scss"
        css = Sass::Engine.for_file(sass_filename,
        	:syntax => :scss,
        	:load_paths => ["./_assets/stylesheets", "./_submodules/toolkit/stylesheets"],
        	:line_numbers => true).render

        File.open(main_file_path, "w+") {|f| f.write(css) }
      rescue StandardError => e
        if e.class.method_defined? :sass_line
          puts "[#{t}] !!! SASS Error - [Line #{e.sass_line}] -- #{e.to_s}"
        else
          puts "!!! Error - #{e.to_s}"
        end
      end
		end
	end
end