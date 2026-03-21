// SPDX-License-Identifier: CC-BY-NC-4.0
import { SectionPage } from '../../components/section-page';
import { sectionContent } from '../../lib/site-data';

export default function InventoryPage() {
  return <SectionPage content={sectionContent.inventory} currentHref="/inventory" />;
}
