Forked from:
mailtrap
    by Matt Mower <self@mattmower.com>
    http://matt.blogs.it/

    modified (and Mailshovel added) by Gwyn Morfey <mail@gwynmorfey.com>

== DESCRIPTION:
    @see https://github.com/mmower/mailtrap

My goal is to let mailtrap write to a temporary datastore (ds) such that ds such that if your app sent an e-mail to tarzan@jane.bah, then ds.next("tarzan@jane.bah") will return as a string and discard the oldest message for tarzan.  In other words, it creates multiple queues, one for each addressee, on an ad hoc basis so that your test script can then fetch the e-mails and test assertions on them.
