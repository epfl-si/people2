# frozen_string_literal: true

# curl https://isa-test.epfl.ch/services/teachers/EDMA/thesis/directors | jq
class IsaThDirectorsGetter < IsaService
  attr_reader :url

  def initialize(args = {})
    progcode = args.delete(:progcode)
    raise "progcode not present in IsaTaGetter" if progcode.blank?

    @url = URI.join(Rails.application.config_for(:epflapi).isa_url,
                    "/services/teachers/#{progcode}/thesis/directors")
  end

  def dofetch
    body = fetch_http
    return nil if body.nil?

    JSON.parse(body).reject do |r|
      r["sciper"].blank? ||
        r["visibility"]["excludeweb"] ||
        r["typeDirecteur"] =~ /^Codirecteur/
    end
  end

  def expire_in
    72.hours
  end
end

# $wsISA_progPhd           = $ISA_url."/teachers/PROGCODE/thesis/directors" ;
# sub getTeachersProgDoct {
#   my ($progcode) = @_;
#   return unless $progcode;

#   $progcode = uc($progcode);

#   my $url = $wsISA_progPhd ;
#      $url =~ s/PROGCODE/$progcode/;
#   my $results = People::Tools::getISA_REST($url) ;

#   my $teachers;
#   foreach my $item (@$results) {
#        next unless $item->{sciper};
#        next if $item->{typeDirecteur} =~ /^Codirecteur/;
#        next if $item->{visibility} && $item->{visibility}->{excludeWeb} eq "true";
#        $teachers->{$item->{sciper}}->{fonction} = $item->{role}->{fr} =~ /prof/i ? 'Prof.' : 'Dr.';
#   }
