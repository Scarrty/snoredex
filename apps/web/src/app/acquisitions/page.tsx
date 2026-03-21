// SPDX-License-Identifier: CC-BY-NC-4.0
import { SectionPage } from '../../components/section-page';
import { sectionContent } from '../../lib/site-data';

export default function AcquisitionsPage() {
  return (
    <SectionPage content={sectionContent.acquisitions} currentHref="/acquisitions" />
  );
}
