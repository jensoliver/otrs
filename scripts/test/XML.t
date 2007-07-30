# --
# XML.t - XML tests
# Copyright (C) 2001-2007 OTRS GmbH, http://otrs.org/
# --
# $Id: XML.t,v 1.9.2.2 2007-07-30 14:01:15 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

use Kernel::System::XML;
use Kernel::System::Ticket;

$Self->{XMLObject} = Kernel::System::XML->new(%{$Self});
$Self->{TicketObject} = Kernel::System::Ticket->new(%{$Self});

my $String = '
    <Contact role="admin" type="organization">
      <Name type="long">Example Inc.</Name>
      <Email type="primary">info@exampe.com<Domain>1234.com</Domain></Email>
      <Email type="secundary">sales@example.com</Email>
      <Telephone country="germany">+49-999-99999</Telephone>
      <Telephone2></Telephone2>
      <SpecialCharacters>\'</SpecialCharacters>
      <SpecialCharacters1>\\\'</SpecialCharacters1>
    </Contact>
';
#       <Germantext>Alle Deutschen Umlaute ��� ��� �</Germantext>

my @XMLHash = $Self->{XMLObject}->XMLParse2XMLHash(String => $String);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{role} eq 'admin',
    'XMLParse2XMLHash()',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{Telephone}->[1]->{country} eq 'germany',
    'XMLHashGet() (Telephone->country)',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{Telephone2}->[1]->{Content} eq '',
    'XMLHashGet() (Telephone2)',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{SpecialCharacters}->[1]->{Content} eq '\'',
    'XMLHashGet() (SpecialCharacters)',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{SpecialCharacters1}->[1]->{Content} eq '\\\'',
    'XMLHashGet() (SpecialCharacters1)',
);

my $XMLHashAdd = $Self->{XMLObject}->XMLHashAdd(
    Type => 'SomeType',
    Key => '123',
    XMLHash => \@XMLHash,
);
$Self->True(
    $XMLHashAdd,
    'XMLHashAdd() (Key=123)',
);

$XMLHashAdd = $Self->{XMLObject}->XMLHashAdd(
    Type => 'SomeType',
    Key => "Some'Key",
    XMLHash => \@XMLHash,
);
$Self->True(
    $XMLHashAdd eq "Some'Key",
    'XMLHashAdd() (Key=Some\'Key)',
);

@XMLHash = $Self->{XMLObject}->XMLHashGet(
    Type => 'SomeType',
    Key => '123',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{role} eq 'admin',
    'XMLHashGet() (admin)',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{Telephone}->[1]->{country} eq 'germany',
    'XMLHashGet() (Telephone->country)',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{Telephone2}->[1]->{Content} eq '',
    'XMLHashGet() (Telephone2)',
);

my @XMLHashUpdate = ();
$XMLHashUpdate[1]->{Contact}->[1]->{role} = 'admin1';
$XMLHashUpdate[1]->{Contact}->[1]->{Name}->[1]->{Content} = 'Example Inc. 2';
my $XMLHashUpdateTrue = $Self->{XMLObject}->XMLHashUpdate(
    Type => 'SomeType',
    Key => '123',
    XMLHash => \@XMLHashUpdate,
);
$Self->True(
    $XMLHashUpdateTrue,
    'XMLHashUpdate() (admin1)',
);

@XMLHash = $Self->{XMLObject}->XMLHashGet(
    Type => 'SomeType',
    Key => '123',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{role} eq 'admin1',
    'XMLHashGet() (admin1)',
);

@XMLHashUpdate = ();
$XMLHashUpdate[1]->{Contact}->[1]->{role} = 'admin';
$XMLHashUpdate[1]->{Contact}->[1]->{Name}->[1]->{Content} = 'Example Inc.';
$XMLHashUpdateTrue = $Self->{XMLObject}->XMLHashUpdate(
    Type => 'SomeType',
    Key => '123',
    XMLHash => \@XMLHashUpdate,
);
$Self->True(
    $XMLHashUpdateTrue,
    'XMLHashUpdate() (admin)',
);

@XMLHash = $Self->{XMLObject}->XMLHashGet(
    Type => 'SomeType',
    Key => '123',
);
$Self->True(
    $#XMLHash == 1 && $XMLHash[1]->{Contact}->[1]->{role} eq 'admin',
    'XMLHashGet() (admin)',
);

my $XML = $Self->{XMLObject}->XMLHash2XML(@XMLHash);
@XMLHash = $Self->{XMLObject}->XMLParse2XMLHash(String => $XML);
my $XML2 = $Self->{XMLObject}->XMLHash2XML(@XMLHash);
$Self->True(
    $XML eq $XML2,
    'XMLHash2XML() -> XMLParse2XMLHash() -> XMLHash2XML()',
);

my $XML3 = $Self->{XMLObject}->XMLHash2XML(@XMLHash);
@XMLHash = $Self->{XMLObject}->XMLParse2XMLHash(String => $XML);
my $XML4 = $Self->{XMLObject}->XMLHash2XML(@XMLHash);
$Self->True(
    ($XML2 eq $XML3 && $XML3 eq $XML4),
    'XMLHash2XML() -> XMLHash2XML() -> XMLParse2XMLHash() -> XMLHash2XML()',
);

my @Keys = $Self->{XMLObject}->XMLHashList(
    Type => 'SomeType',
);
$Self->True(
    ($Keys[0] == 123),
    'XMLHashList() ([0] == 123)',
);

foreach my $Key (@Keys) {
    my $XMLHashDelete = $Self->{XMLObject}->XMLHashDelete(
        Type => 'SomeType',
        Key => $Key,
    );
    $Self->True(
        $XMLHashDelete,
        "XMLHashDelete() (Key=$Key)",
    );
}

$XMLHashAdd = $Self->{XMLObject}->XMLHashAdd(
    Type => 'SomeType',
    KeyAutoIncrement => 1,
    XMLHash => \@XMLHash,
);
$Self->True(
    $XMLHashAdd eq 1,
    'XMLHashAdd() (1 KeyAutoIncrement)',
);

$XMLHashAdd = $Self->{XMLObject}->XMLHashAdd(
    Type => 'SomeType',
    KeyAutoIncrement => 1,
    XMLHash => \@XMLHash,
);
$Self->True(
    $XMLHashAdd eq 2,
    'XMLHashAdd() (2 KeyAutoIncrement)',
);

@Keys = $Self->{XMLObject}->XMLHashList(
    Type => 'SomeType',
);
foreach my $Key (@Keys) {
    my $XMLHashDelete = $Self->{XMLObject}->XMLHashDelete(
        Type => 'SomeType',
        Key => $Key,
    );
    $Self->True(
        $XMLHashDelete,
        "XMLHashDelete() 2 (Key=$Key)",
    );
}
#------------------------------------------------#
# a test to find charset problems with xml files
#------------------------------------------------#

# get the example xml
my $Path = $Self->{ConfigObject}->Get('Home');
$Path .= "/scripts/test";
my $File = 'XML-Test-file.xml';
$String = '';
if (open (DATA, "< $Path/$File")) {
    while (<DATA>) {
        $String .= $_;
    }
    close (DATA);

    @XMLHash = $Self->{XMLObject}->XMLParse2XMLHash(String => $String);
    $Self->True(
       $#XMLHash == 1 && $XMLHash[1]->{'EISPP-Advisory'}->[1]->{System_Information}->[1]->{information},
       'XMLParse2XMLHash() - charset test - use file form the filesystem and parse it',
    );

    my $TicketID = $Self->{TicketObject}->TicketCreate(
        Title => 'Some Ticket Title',
        Queue => 'Raw',
        Lock => 'unlock',
        Priority => '3 normal',
        State => 'closed successful',
        CustomerNo => '123465',
        CustomerUser => 'customer@example.com',
        OwnerID => 1,
        UserID => 1,
    );
    $Self->True(
        $TicketID,
        'XMLParse2XMLHash() - charset test - create ticket',
    );

    my $ArticleID = $Self->{TicketObject}->ArticleCreate(
        TicketID => $TicketID,
        ArticleType => 'note-internal',
        SenderType => 'agent',
        From => 'Some Agent <email@example.com>',
        To => 'Some Customer <customer-a@example.com>',
        Cc => 'Some Customer <customer-b@example.com>',
        ReplyTo => 'Some Customer <customer-b@example.com>',
        Subject => 'some short description',
        Body => 'the message text Perl modules provide a range of featurheel, and can be downloaded',
        ContentType => 'text/plain; charset=ISO-8859-15',
        HistoryType => 'OwnerUpdate',
        HistoryComment => 'Some free text!',
        UserID => 1,
        NoAgentNotify => 1,            # if you don't want to send agent notifications
    );

    $Self->True(
        $ArticleID,
        'XMLParse2XMLHash() - charset test - create article',
    );

    my $Feedback = $Self->{TicketObject}->ArticleWriteAttachment(
        Content => $String,
        ContentType => 'text/html; charset="iso-8859-15"',
        Filename => $File,
        ArticleID => $ArticleID,
        UserID => 1,
    );
    $Self->True(
        $Feedback,
        'XMLParse2XMLHash() - charset test - write an article attachemnt to storage',
    );

    my %Attachment = $Self->{TicketObject}->ArticleAttachment(
        ArticleID => $ArticleID,
        FileID => 1,
        UserID => 1,
    );

    @XMLHash = $Self->{XMLObject}->XMLParse2XMLHash(String => $Attachment{Content});
    $Self->True(
       $#XMLHash == 1 && $XMLHash[1]->{'EISPP-Advisory'}->[1]->{System_Information}->[1]->{information},
       'XMLParse2XMLHash() - charset test - use file form the articleattachement and parse it',
    );

}
else {
    $Self->True(
        0,
        "XMLParse2XMLHash() - charset test - failed because example file not found",
    );
}

1;
