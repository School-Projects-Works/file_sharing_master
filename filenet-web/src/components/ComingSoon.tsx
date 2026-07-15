import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function ComingSoon({ title, phase }: { title: string; phase: string }) {
  return (
    <Card className="mx-auto max-w-lg">
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="text-sm text-muted-foreground">
        This screen is being built in {phase}. The underlying data and permissions already
        work end-to-end — this page just doesn't have a UI on top of it yet.
      </CardContent>
    </Card>
  );
}
