module Jekyll
	require 'sass'
	class SassGenerator < Generator
		safe true
		priority :low
		
		def generate(site)
			begin
        t = Time.now.strftime("%Y-%m-%d %H:%M:%S");
        puts "[#{t}] Performing Sass Conversion."
        sass_filename = "./_assets/stylesheets/main.scss"
        css = Sass::Engine.for_file(sass_filename, 
        	:syntax => :scss, 
        	:load_paths => ["./_assets/stylesheets", "./_submodules/toolkit/stylesheets"], 
        	:line_numbers => true).render
        File.open("./assets/stylesheets/main.css", "wb") {|f| f.write(css) }
      rescue StandardError => e
        puts "[#{t}] !!! SASS Error - [Line #{e.sass_line}] -- #{e.to_s}"
      end
		end
	end
end