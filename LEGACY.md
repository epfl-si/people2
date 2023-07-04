# Notes about the old people application
People have to main main sources of data:
  1. official personal data (name, accreditations, etc.) from read-only DBs and APIs.
  2. people-specific biography / curriculum vitae data that can be edited by the user

In the old applications, bio data were organized in _boxes_. Two main types of
boxes and three special cases: 
1. title + free text
  - Biography (pos B, undeletable, frozen title)
  - Biography free (pos B) e.g. "mission", "current work"
  - Free Contact boxes (pos K) is added below the social ids zone on the left
  - Research (pos R)
  - Teaching related free content (pos T)
2. specialized models (the box is a list of instances of the model)
  - Education (model Education/edu, pos B, fields: title, description, institution, dates)
  - Professional Course (model Experience/parcours, pos B, fields: title, description, institution, dates)
  - Awards (model Award/awards, pos B, fields: title, description, url, dates)
  - Selected Publications (model Publication/publications, pos P, fields: authors, title, revue, link)
  - Achievements (model Achievement/achievements, system V, pos B, fields: category, description, url, year
4. Infoscience Publications are currently stored in the boxes table but should be moved to and _ad-hoc_ model because they have a special logic and caching mechanism. The `src` column in `boxes` is actually used exclusively by this model.
5. The `profresearch` table is full of interesting infos but, for some reason, it is no longer editable and only used as a fallback for awards when those are not present.

Boxes are divided in blocks
 - Contact block (pos K)
 - Biography block (pos B) also includes Education and Professional Course
 - Publication block (pos P)
 - Research block (pos R)
 - Teaching block (pos T)


```perl
my $systemboxes = {
  bio => {
    label => {
      fr  => 'Biographie',
      en  => 'Biography',
    },
    position => 'B',
    sys => '',
  },
  edu => {
    label => {
      fr  => 'Formation',
      en  => 'Education',
    },
    position => 'B',
    sys => 'E',
  },
  parcours => {
    label => {
      fr  => 'Parcours professionnel',
      en  => 'Profesional Course',
    },
    position => 'B',
    sys => 'C',
  },
  achievements => {
    label => {
      fr  => 'Réalisations annuelles',
      en  => 'Annual Achievements',
    },
    position => 'B',
    sys => 'V',
  },
  awards => {
    label => {
      fr  => 'Récompenses',
      en  => 'Awards',
    },
    position => 'B',
    sys => 'A',
  },
  publ => {
    label => {
      fr  => 'Sélection de publications',
      en  => 'Selected publications',
    },
    position => 'P',
    sys => 'P',
  },
};
my @systemBoxesOrder = ('bio', 'edu', 'parcours', 'awards', 'publ', 'achievements');
sub initBoxes {
  my $self   = shift;
  my $sciper = shift;
  my $cvlang = shift;
  return unless $sciper && $cvlang;
  my $dbh    = $self->{dbh};
  my $ordre = 0;
  foreach my $box_type (@systemBoxesOrder) {
    next unless $box_type;
    my $box = $systemboxes->{$box_type};
    my $sql = qq{
      insert into cv.boxes set
        sciper=?,
        cvlang=?,
        label=?,
        position=?,
        sys=?,
        ordre=?
    };
    my $sth = $dbh->prepare( $sql ) or die "** ERR people prepare :$sql: $DBI::errstr\n";
    $sth->execute ($sciper, $cvlang, $box->{label}->{$cvlang}, $box->{position}, $box->{sys}, $ordre) or die "** RR execute : $DBI::errstr\n$sql\n";
    $ordre++;
  }
}
```

## Importing boxes
Boxes contain all sort of crap. It will be hard to auto-migrate. 
I think we should do it by hand (e.g. @ SDF) and only for currently active people.


## New Structure
### First attempt
 * Section: the various sections of the Cv page with localized title.
   - title_en
   - title_fr
   - label
   - zone
   - position
   - show_title
   - create_allowed
   - have_many :boxes
   - has_many :model_boxes
 * ModelBox: the standard boxes that will be used as templates for the boxes
   that will be automatically added to each profile. 
   - label
   - locale
   - title
   - show_title
   - position
   - belongs_to :section
 * Box: the actual boxes for the user profiles.  
   - locale
   - title
   - show_title
   - frozen
   - kind
   - visible
   - position
   - belongs_to :cv
   - belongs_to :section

Pros: 
 - similar to the current implementation;
 - extensible multilanguage (more languages can be added later)
Cons:
 - not very general wrt the fact of having different types of boxes (e.g. education, awards, etc)
 - the fact of creating the boxes from model boxes for each profile will introduce a lot of useless lines in the database and complicates testing. It is probably better to only create the used boxes and allow to chose the template upon creation.


 