# frozen_string_literal: true

module API
  module V0
    class CoursesController < LegacyBaseController
      def index
        # if query string got format=html
        raise NotImplementedError if params["format"] != "html"

        # Mock data
        @courses = [OpenStruct.new(
          title: "Drawing structures",
          teachers: ["Fernandez-Ordoñez Hernandez David Carlos", "Baur Raffael", "Guaita Patricia"],
          slug: "CIVIL-126",
          isa_url: "http://isa.epfl.ch/imoniteur_ISAP/!itffichecours.htm?ww_i_matiere=3928308740&ww_x_anneeacad=2840683608&ww_i_section=942623&ww_i_niveau=6683111&ww_c_langue=fr",
          semester: "Génie civil-Bachelor semestre 1",
          curricular_year: "'2025-2026"
        ),
        OpenStruct.new(
          title: "Engineering a sustainable built environment",
          teachers: ["Sonta Andrew James"],
          slug: "CIVIL-126",
          isa_url: "http://isa.epfl.ch/imoniteur_ISAP/!itffichecours.htm?ww_i_matiere=3928308740&ww_x_anneeacad=2840683608&ww_i_section=942623&ww_i_niveau=6683111&ww_c_langue=fr",
          semester: "Génie civil-Bachelor semestre 1",
          curricular_year: "'2025-2026"
        )]
        render 'api/v0/courses/index', layout: false
      end
    end
  end
end
