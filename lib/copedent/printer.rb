# handles all output for the program
module Copedent
  class Printer
    def self.print_to_terminal(analysis:, max_visible_frets:)
      puts "Printing valid chords to terminal..."

      analysis.take(max_visible_frets).map do |col|
        puts Terminal::Table.new(
          headings: ["Fr", "Str", "Note", "#", "Name"],
          rows: col
        )
      end
    end

    def self.export_csv(analysis:, filename:)
      puts "Exporting valid chords to CSV at #{CSV_FILENAME}..."

      CSV.open(filename, "w") do |csv|
        csv << ["Fret", "Str", "Note", "#", "Name"] * analysis.length

        analysis.transpose.each { |row| csv << row.flatten }
      end
    end
  end
end
