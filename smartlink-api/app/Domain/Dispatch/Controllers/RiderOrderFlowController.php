<?php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class RiderOrderFlowController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function uploadPickupProof(Request $request, Order $order)
    {
        $request->validate([
            'video' => ['required', 'file', 'mimetypes:video/mp4,video/quicktime,video/x-matroska', 'max:51200'],
        ]);

        $disk = (string) config('smartlink.media_disk', 'local');
        $file = $request->file('video');

        $path = Storage::disk($disk)->putFileAs(
            "orders/{$order->id}/evidence",
            $file,
            'pickup-'.Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
        );

        try {
            $evidence = $this->dispatchService->uploadPickupProof(
                $request->user(),
                $order,
                Storage::disk($disk)->url($path),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 403);
        }

        return response()->json([
            'id' => $evidence->id,
            'file_url' => $evidence->file_url,
        ]);
    }

    public function markPickedUp(Request $request, Order $order)
    {
        try {
            $updated = $this->dispatchService->markPickedUp($request->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['message' => 'Marked as picked up.', 'status' => $updated->status->value]);
    }

    public function markDelivered(Request $request, Order $order)
    {
        try {
            $request->validate([
                'delivery_otp' => ['nullable', 'string', 'max:10'],
            ]);

            $updated = $this->dispatchService->markDelivered(
                $request->user(),
                $order,
                null,
                $request->input('delivery_otp'),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Marked as delivered.',
            'status' => $updated->status->value,
            'escrow_hold_expires_at' => optional($updated->escrowHold?->hold_expires_at)?->toISOString(),
        ]);
    }

    public function uploadDeliveryProof(Request $request, Order $order)
    {
        $request->validate([
            'photo' => ['required', 'file', 'mimetypes:image/jpeg,image/png,image/webp', 'max:5120'],
        ]);

        $disk = (string) config('smartlink.media_disk', 'local');
        $file = $request->file('photo');

        $path = Storage::disk($disk)->putFileAs(
            "orders/{$order->id}/evidence",
            $file,
            'delivery-'.Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
        );

        try {
            $evidence = $this->dispatchService->uploadDeliveryProof(
                $request->user(),
                $order,
                Storage::disk($disk)->url($path),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 403);
        }

        return response()->json([
            'id' => $evidence->id,
            'file_url' => $evidence->file_url,
        ]);
    }
}
